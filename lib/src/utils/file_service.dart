import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:video_compress/video_compress.dart';
import 'package:path_provider/path_provider.dart';
import '../models/file_model.dart';
import '../models/settings_model.dart';
import 'web_compression_service.dart' if (dart.library.io) 'web_compression_service_stub.dart';

class FileService {
  final WebCompressionService? _webService = kIsWeb ? WebCompressionService() : null;
  Future<List<FileModel>> pickFiles(MediaType type) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withData: kIsWeb, // Important for web
      type: type == MediaType.video 
          ? FileType.video 
          : type == MediaType.image 
            ? FileType.image 
            : FileType.custom,
      allowedExtensions: type == MediaType.pdf ? ['pdf'] : null,
    );

    if (result != null) {
      List<FileModel> models = [];
      for (var file in result.files) {
        // On web, path is unavailable. Use bytes.
        File? ioFile;
        if (!kIsWeb && file.path != null) {
          ioFile = File(file.path!);
        }

        FileMeta meta = const FileMeta();
        if (type == MediaType.video) {
           if (!kIsWeb && ioFile != null) {
             try {
               final info = await VideoCompress.getMediaInfo(ioFile.path);
               meta = FileMeta(
                 duration: (info.duration ?? 0) / 1000,
                 width: info.width ?? 0,
                 height: info.height ?? 0,
               );
             } catch (e) {
               print("Error getting video info: $e");
             }
           }
           // On web, maybe get info from bytes? (Harder)
        } else if (type == MediaType.image) {
             if (kIsWeb && file.bytes != null) {
                // Decode from bytes
                try {
                  final image = await decodeImageFromList(file.bytes!);
                  meta = FileMeta(width: image.width, height: image.height);
                } catch (e) {
                  print("Error decoding image: $e");
                }
             } else if (ioFile != null) {
                try {
                  final bytes = await ioFile.readAsBytes();
                  final image = await decodeImageFromList(bytes);
                  meta = FileMeta(width: image.width, height: image.height);
                } catch (e) {
                  print("Error decoding image: $e");
                }
             }
        }

        models.add(FileModel(
          id: DateTime.now().millisecondsSinceEpoch.toString() + file.name,
          file: ioFile,
          bytes: file.bytes,
          name: file.name,
          type: type,
          originalSize: file.size,
          meta: meta, 
        ));
      }
      return models;
    }
    return [];
  }

  Future<FileModel> compressVideo(FileModel file, AppSettings settings, {Function(int)? onProgress, bool Function()? isCancelled}) async {
    // Use web compression service on web
    if (kIsWeb) {
      return await _webService!.compressVideo(file, settings, onProgress: onProgress);
    }
    
    if (file.file == null) {
      return file.copyWith(status: FileStatus.error);
    }
    
    // Check cancellation before starting
    if (isCancelled?.call() ?? false) {
      return file.copyWith(status: FileStatus.cancelled);
    }

    VideoQuality quality = VideoQuality.DefaultQuality;
    
    if (settings.mode == 'smart') {
      if (settings.qualityLevel == 'low') quality = VideoQuality.LowQuality;
      else if (settings.qualityLevel == 'medium') quality = VideoQuality.MediumQuality;
      else quality = VideoQuality.HighestQuality;
    } else if (settings.mode == 'resolution') {
       if (settings.targetResolution == '1080p') quality = VideoQuality.Res1920x1080Quality;
       else if (settings.targetResolution == '720p') quality = VideoQuality.Res1280x720Quality;
       else if (settings.targetResolution == '480p') quality = VideoQuality.Res640x480Quality;
       else quality = VideoQuality.Res640x480Quality;
    }

    try {
      final mediaInfo = await VideoCompress.compressVideo(
        file.file!.path,
        quality: quality,
        deleteOrigin: settings.deleteOriginal,
        includeAudio: !settings.removeAudio,
        frameRate: settings.mode == 'custom' ? settings.fps : 30,
      );

      // We cannot easily cancel VideoCompress mid-stream with this plugin, 
      // but we can check after it finishes.
      if (isCancelled?.call() ?? false) {
           return file.copyWith(status: FileStatus.cancelled);
      }

      if (mediaInfo != null && mediaInfo.file != null) {
        return file.copyWith(
          status: FileStatus.done,
          progress: 100,
          resultFile: mediaInfo.file,
          resultSize: mediaInfo.filesize,
        );
      }
    } catch (e) {
      if (e.toString().contains('Cancel')) {
         return file.copyWith(status: FileStatus.cancelled);
      }
      print("Video compression failed: $e");
    }
    return file.copyWith(status: FileStatus.error);
  }

  Future<FileModel> compressImage(FileModel file, PhotoSettings settings, {bool Function()? isCancelled}) async {
    if (file.file == null && file.bytes == null) {
        return file.copyWith(status: FileStatus.error);
    }

    if (isCancelled?.call() ?? false) return file.copyWith(status: FileStatus.cancelled);

    try {
      if (kIsWeb) {
         if (isCancelled?.call() ?? false) return file.copyWith(status: FileStatus.cancelled);
         // Web Image Compression logic
         var result = await FlutterImageCompress.compressWithList(
           file.bytes!,
           minWidth: (file.meta.width * settings.resize).toInt(),
           minHeight: (file.meta.height * settings.resize).toInt(),
           quality: (settings.quality * 100).toInt(),
         );
         
         if (isCancelled?.call() ?? false) return file.copyWith(status: FileStatus.cancelled);

         return file.copyWith(
           status: FileStatus.done, 
           progress: 100, 
           resultSize: result.length,
           bytes: result, // Store result bytes for web download
         ); 
      }

      final dir = await getTemporaryDirectory();
      final targetPath = "${dir.absolute.path}/temp_${DateTime.now().millisecondsSinceEpoch}_${file.name}";
      
      var result = await FlutterImageCompress.compressAndGetFile(
        file.file!.absolute.path,
        targetPath,
        quality: (settings.quality * 100).toInt(),
        minWidth: (file.meta.width * settings.resize).toInt(),
        minHeight: (file.meta.height * settings.resize).toInt(),
      );

      if (isCancelled?.call() ?? false) return file.copyWith(status: FileStatus.cancelled);

      if (result != null) {
        final size = await result.length();
        return file.copyWith(
          status: FileStatus.done,
          progress: 100,
          resultFile: File(result.path),
          resultSize: size,
        );
      }
    } catch (e) {
      print("Image compression failed: $e");
    }
    return file.copyWith(status: FileStatus.error);
  }

  Future<FileModel> compressPDF(FileModel file, PDFSettings settings, {Function(int)? onProgress, bool Function()? isCancelled}) async {
    // Simulated PDF compression
    int progress = 10;
    
    // Initial progress
    onProgress?.call(progress);
    
    // Simulate time passing (5 intervals of 100ms) to match React's logic somewhat
    for (int i = 0; i < 9; i++) {
        if (isCancelled?.call() ?? false) return file.copyWith(status: FileStatus.cancelled);

        await Future.delayed(const Duration(milliseconds: 100));
        progress += 10;
        onProgress?.call(progress);
    }

    if (isCancelled?.call() ?? false) return file.copyWith(status: FileStatus.cancelled);

    // Determine simulated reduction
    // React logic: 0.6 + (Math.random() * 0.2)
    final random = (DateTime.now().millisecondsSinceEpoch % 100) / 100.0; // Simple pseudo-random
    final factor = 0.6 + (0.2 * random);
    final simulatedSize = (file.originalSize * factor).toInt();

    return file.copyWith(
      status: FileStatus.done,
      progress: 100,
      resultSize: simulatedSize,
      bytes: file.bytes, // Store bytes for download assumption
      resultFile: file.file,
    );
  }
}
