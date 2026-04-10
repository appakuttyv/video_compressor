import 'dart:io';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:video_compress/video_compress.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'src/utils/share_utils.dart'; // Abstract
import 'src/utils/share_utils_stub.dart' // Factory/Impl
    if (dart.library.io) 'src/utils/share_utils_io.dart'
    if (dart.library.html) 'src/utils/share_utils_web.dart';
import 'src/models/file_model.dart';
import 'src/models/settings_model.dart';
import 'src/models/processed_file.dart';
import 'src/screens/dashboard.dart';
import 'src/screens/selection_screen.dart';
import 'src/screens/settings_screen.dart';
import 'src/screens/processing_screen.dart';
import 'src/screens/result_screen.dart';
import 'src/screens/file_manager.dart';
import 'src/utils/file_service.dart';
import 'src/utils/storage_service.dart';
import 'src/utils/download_utils.dart';
import 'src/utils/download_utils_stub.dart'
    if (dart.library.html) 'src/utils/download_utils_web.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Video Compressor',
      home: App(),
    );
  }
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  // Theme State
  bool isDarkMode = true;

  // Navigation & Data State
  String currentScreen = 'dashboard';
  MediaType activeMediaType = MediaType.video;
  List<FileModel> files = [];
  
  // Storage tracking
  final StorageService _storageService = StorageService();
  Map<String, int> storageInfo = {'total': 0, 'used': 0, 'free': 0};
  Map<String, int> mediaBreakdown = {'videos': 0, 'photos': 0, 'docs': 0};
  List<ProcessedFile> recentFiles = [];

  // Advanced Settings State
  AppSettings settings = AppSettings(
    mode: 'smart',
    qualityLevel: 'medium',
    targetResolution: '720p',
    bitrate: 2.5,
    fps: 30,
    removeAudio: false,
    deleteOriginal: false,
  );

  PhotoSettings photoSettings = PhotoSettings(
    quality: 0.8,
    resize: 1.0,
    format: 'image/jpeg',
  );

  PDFSettings pdfSettings = PDFSettings();

  // Services
  final FileService _fileService = FileService();
  final DownloadUtils _downloadUtils = DownloadUtilsImpl();

  @override
  void initState() {
    super.initState();
    _loadStorageData();
    _loadRecentFiles();
    // Listen to video compression progress
    VideoCompress.compressProgress$.subscribe((progress) {
      if (!mounted) return; // Safety check
      setState(() {
         // Update progress of the currently processing file
         final processingFileIndex = files.indexWhere((f) => f.status == FileStatus.processing);
         if (processingFileIndex != -1) {
           files[processingFileIndex].progress = progress.toInt();
         }
      });
    });
  }

  void _toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  Future<void> _loadStorageData() async {
    final info = await _storageService.getStorageInfo();
    final breakdown = await _storageService.getMediaStorageBreakdown();
    if (mounted) {
       setState(() {
         storageInfo = info;
         mediaBreakdown = breakdown;
       });
    }
  }

  Future<void> _loadRecentFiles() async {
    final recent = await _storageService.getRecentFiles();
    if (mounted) {
      setState(() {
        recentFiles = recent;
      });
    }
  }

  Future<void> _handleFileSelect(MediaType type) async {
    setState(() {
      activeMediaType = type;
    });
    
    // Pick files based on type
    final picked = await _fileService.pickFiles(type);
    if (picked.isNotEmpty) {
      setState(() {
        files = picked;
        currentScreen = 'selection';
      });
    }
  }
  
  void _handleSessionDownload() async {
      final doneFiles = files.where((f) => f.status == FileStatus.done).toList();
      if (doneFiles.isEmpty) return;

      for (var f in doneFiles) {
          if (f.bytes != null) {
               await _downloadUtils.downloadFile("compressed_${f.name}", f.bytes!);
          }
      }
  }

  void _handleRecentDownload(ProcessedFile file) async {
      if (file.bytes != null) {
          await _downloadUtils.downloadFile("compressed_${file.name}", file.bytes!);
      } else {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('File content not available for download')),
          );
      }
  }

  Set<String> _cancelledFileIds = {};

  void _startProcessing() async {
    setState(() {
      currentScreen = 'processing';
      _cancelledFileIds.clear();
    });

    final filesToProcess = files.where((f) => f.selected && f.status != FileStatus.done).toList();

    for (var file in filesToProcess) {
      // Check for global or specific cancellation
      if (_cancelledFileIds.contains(file.id)) {
           setState(() {
             final index = files.indexWhere((f) => f.id == file.id);
             if (index != -1) {
               files[index].status = FileStatus.cancelled;
             }
           });
           // Save cancelled file to history
           await _saveProcessedFile(files.firstWhere((f) => f.id == file.id));
           continue; 
      }

      // Update status to processing
      setState(() {
        final index = files.indexWhere((f) => f.id == file.id);
        if (index != -1) {
          files[index].status = FileStatus.processing;
          files[index].progress = 0;
        }
      });

      FileModel processedFile;
      if (file.type == MediaType.video) {
        processedFile = await _fileService.compressVideo(
          file, 
          settings,
          onProgress: (p) {
            if (!mounted) return;
            setState(() {
              final index = files.indexWhere((f) => f.id == file.id);
              if (index != -1) files[index].progress = p;
            });
          },
          isCancelled: () => _cancelledFileIds.contains(file.id),
        );
      } else if (file.type == MediaType.image) {
        processedFile = await _fileService.compressImage(
            file, 
            photoSettings,
            isCancelled: () => _cancelledFileIds.contains(file.id)
        );
      } else {
        processedFile = await _fileService.compressPDF(
            file, 
            pdfSettings,
            onProgress: (p) {
                if (!mounted) return;
                setState(() {
                  final index = files.indexWhere((f) => f.id == file.id);
                  if (index != -1) files[index].progress = p;
                });
            },
            isCancelled: () => _cancelledFileIds.contains(file.id),
        );
      }

      if (!mounted) return;

      // Update status
      setState(() {
        final index = files.indexWhere((f) => f.id == file.id);
        if (index != -1) {
          files[index] = processedFile;
        }
      });

      // Save to persistent storage (Done or Cancelled)
      if (processedFile.status == FileStatus.done || processedFile.status == FileStatus.cancelled) {
         await _saveProcessedFile(processedFile);
      }
    }

    if (!mounted) return;
    
    // Check if any files are actually done to show result screen, else go back or show cancelled info
    final hasDoneFiles = files.any((f) => f.status == FileStatus.done);
    if (hasDoneFiles) {
        setState(() {
          currentScreen = 'result';
        });
    } else {
        setState(() {
           currentScreen = 'dashboard';
        });
    }
  }

  Future<void> _saveProcessedFile(FileModel processedFile) async {
        final processedFileRecord = ProcessedFile(
          id: processedFile.id,
          name: processedFile.name,
          type: processedFile.type == MediaType.video ? 'video' : processedFile.type == MediaType.image ? 'image' : 'pdf',
          originalSize: processedFile.originalSize,
          resultSize: processedFile.resultSize,
          processedDate: DateTime.now(),
          bytes: processedFile.bytes, 
          savedPath: processedFile.resultFile?.path,
          status: processedFile.status == FileStatus.cancelled ? 'cancelled' : 'done',
          originalPath: processedFile.file?.path, // Save original path
        );
        await _storageService.saveProcessedFile(processedFileRecord);
        
        await _loadRecentFiles();
        
        setState(() {
          final index = recentFiles.indexWhere((f) => f.id == processedFileRecord.id);
          if (index != -1) {
            recentFiles[index].bytes = processedFile.bytes;
          }
        });

        await _loadStorageData();
  }

  void _retryFile(ProcessedFile file) {
      if (file.originalPath == null) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Original file path missing")));
          return;
      }

      // Create a FileModel from ProcessedFile
      final newFile = FileModel(
          id: file.id, // Reuse ID to match? Or new ID? Reuse ID to update the item in place if we want inline progress matching.
          // Actually if I reuse ID, the Dashboard item (ProcessedFile) will match the FileModel ID.
          name: file.name,
          file: File(file.originalPath!),

          originalSize: file.originalSize,
          type: file.type == 'video' ? MediaType.video : file.type == 'image' ? MediaType.image : MediaType.pdf,
          selected: true,
          status: FileStatus.idle,
      );

      setState(() {
          // Add to files if not exists, or replace?
          // If I add to files, _startProcessing will pick it up.
          // Note context: "recent list".
          // If I reuse ID, the "recent file" (history) and "active file" (queue) share ID.
          // When processing updates, does it update "recent files"?
          // No, recent files are loaded from storage.
          // But I can pass `files` to Dashboard to overlay progress.
          
          // Allow multiple retries?
          // Remove existing if any
          files.removeWhere((f) => f.id == file.id);
          files.clear(); // Clear previous session to focus on retry? Or append?
          // User might want to retry multiple. Append is safer.
          // But `files` usually represents the "Selection" session.
          // I'll append.
          files.add(newFile);
          
          // Remove from cancelled list if there
          _cancelledFileIds.remove(file.id);
      });

      // Start processing immediately?
      _startProcessing();
      
      // Navigate to processing? Or stay?
      // User said "progress in the same recent list it self".
      // So STAY on Dashboard.
      // currentScreen = 'dashboard'; (Already there)
  }

  void _cancelProcessing() {
      // Cancel all remaining
      setState(() {
          for (var f in files) {
             if (f.status == FileStatus.idle || f.status == FileStatus.processing) {
                 _cancelledFileIds.add(f.id);
             }
          }
      });
  }

  void _cancelItem(String id) {
      setState(() {
          _cancelledFileIds.add(id);
      });
  }

  // Use the abstract class, the factory consturctor or conditional import will provide the right impl
  final ShareUtils _shareUtils = ShareUtilsImpl();

  void _shareFile(ProcessedFile file) async {
    await _shareUtils.shareFile(file);
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0a0a0a) : const Color(0xFFF8FAFC), // White-ish background for light mode
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _buildScreen(),
        ),
      ),
    );
  }

  Widget _buildScreen() {
    switch (currentScreen) {
      case 'dashboard':
        return DashboardScreen(
          isDarkMode: isDarkMode,
          onThemeToggle: _toggleTheme,
          onSelectType: _handleFileSelect,
          recentFiles: recentFiles,
          usedStorage: storageInfo['used'] ?? 0,
          quotaStorage: storageInfo['total'] ?? 1,
          videoStorage: mediaBreakdown['videos'] ?? 0,
          photoStorage: mediaBreakdown['photos'] ?? 0,
          docStorage: mediaBreakdown['docs'] ?? 0,
          onDownload: _handleRecentDownload,
          onFileManager: () => setState(() => currentScreen = 'fileManager'),
          onShare: _shareFile,
          onRetry: _retryFile,
          activeFiles: files,
        );
      case 'fileManager':
        return FileManagerScreen(
           isDarkMode: isDarkMode,
           onThemeToggle: _toggleTheme,
           onBack: () => setState(() => currentScreen = 'dashboard'),
           files: recentFiles,
           onDelete: (id) async {
             await _storageService.deleteProcessedFile(id);
             await _loadRecentFiles();
             await _loadStorageData();
           },
        );
      case 'selection':
        return SelectionScreen(
          isDarkMode: isDarkMode,
          onThemeToggle: _toggleTheme,
          onBack: () => setState(() { currentScreen = 'dashboard'; files = []; }), 
          activeMediaType: activeMediaType,
          files: files,
          onToggleSelect: (id) => setState(() {
            final index = files.indexWhere((f) => f.id == id);
            if (index != -1) {
              files[index].selected = !files[index].selected;
            }
          }),
          onSelectAll: () => setState(() {
            final allSelected = files.every((f) => f.selected);
            for (var f in files) {
              f.selected = !allSelected;
            }
          }),
          onContinue: () => setState(() => currentScreen = 'settings'),
        );
      case 'settings':
        return SettingsScreen(
          isDarkMode: isDarkMode,
          activeMediaType: activeMediaType,
          settings: settings,
          photoSettings: photoSettings,
          pdfSettings: pdfSettings,
          selectedFiles: files.where((f) => f.selected).toList(),
          onUpdateSettings: (newSettings) => setState(() => settings = newSettings),
          onUpdatePhotoSettings: (newSettings) => setState(() => photoSettings = newSettings),
          onUpdatePDFSettings: (newSettings) => setState(() => pdfSettings = newSettings),
          onStartProcessing: _startProcessing,
          onCancel: () => setState(() => currentScreen = 'selection'),
        );
      case 'processing':
        return ProcessingScreen(
          isDarkMode: isDarkMode,
          files: files,
          onCancel: _cancelProcessing,
          onCancelItem: _cancelItem,
        );
      case 'result':
        return ResultScreen(
          isDarkMode: isDarkMode,
          files: files,
          onSaveAll: () {
             // Save action
          },
          onDone: () => setState(() {
            currentScreen = 'dashboard';
            files = []; // Clear current session
          }),
        );
      default:
        return const Center(child: Text("Unknown Screen"));
    }
  }
}
