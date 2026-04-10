import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../components/header.dart';
import '../components/storage_card.dart';
import '../components/action_button.dart';
import '../models/file_model.dart';
import '../models/processed_file.dart';
import '../utils/format_utils.dart';

class DashboardScreen extends StatelessWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;
  final Function(MediaType) onSelectType;
  final List<ProcessedFile> recentFiles;
  final int usedStorage;
  final int quotaStorage;
  final int videoStorage;
  final int photoStorage;
  final int docStorage; // New prop
  final Function(ProcessedFile)? onDownload;
  final VoidCallback? onFileManager;
  final Function(ProcessedFile)? onShare; // New callback
  final Function(ProcessedFile)? onRetry; // New callback
  final List<FileModel> activeFiles; // New prop for inline progress

  const DashboardScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
    required this.onSelectType,
    required this.recentFiles,
    required this.usedStorage,
    required this.quotaStorage,
    required this.videoStorage,
    required this.photoStorage,
    this.docStorage = 0,
    this.onDownload,
    this.onFileManager,
    this.onShare,
    this.onRetry,
    this.activeFiles = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Header(
          title: "My Space",
          isDarkMode: isDarkMode,
          onThemeToggle: onThemeToggle,
        ),
        StorageCard(
          used: usedStorage,
          quota: quotaStorage,
          videoStorage: videoStorage,
          photoStorage: photoStorage,
          docStorage: docStorage,
          isDarkMode: isDarkMode,
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader("TOOLS", isDarkMode),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.2,
                    children: [
                      ActionButton(
                        icon: LucideIcons.fileVideo,
                        label: "Compress Video",
                        color: Colors.white, 
                        iconColor: isDarkMode ? const Color(0xFF818CF8) : const Color(0xFF3B82F6),
                        backgroundColor: isDarkMode ? const Color(0xFF312E81) : const Color(0xFFEFF6FF),
                        isDarkMode: isDarkMode,
                        onClick: () => onSelectType(MediaType.video),
                      ),
                      ActionButton(
                        icon: LucideIcons.image,
                        label: "Photo Magic",
                         color: Colors.white,
                        iconColor: isDarkMode ? const Color(0xFFF472B6) : const Color(0xFFEC4899),
                        backgroundColor: isDarkMode ? const Color(0xFF831843) : const Color(0xFFFDF2F8),
                        isDarkMode: isDarkMode,
                        onClick: () => onSelectType(MediaType.image),
                      ),
                      ActionButton(
                        icon: LucideIcons.fileText, 
                        label: "PDF Compress",
                         color: Colors.white,
                        iconColor: isDarkMode ? const Color(0xFFF87171) : const Color(0xFFEF4444),
                        backgroundColor: isDarkMode ? const Color(0xFF7F1D1D).withOpacity(0.5) : const Color(0xFFFEF2F2),
                        isDarkMode: isDarkMode,
                        onClick: () => onSelectType(MediaType.pdf),
                      ),
                      ActionButton(
                        icon: LucideIcons.folderOpen,
                        label: "File Manager",
                         color: Colors.white,
                        iconColor: isDarkMode ? const Color(0xFF34D399) : const Color(0xFF059669),
                        backgroundColor: isDarkMode ? const Color(0xFF064E3B).withOpacity(0.5) : const Color(0xFFECFDF5),
                        isDarkMode: isDarkMode,
                        onClick: onFileManager,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "RECENT",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                          color: isDarkMode ? Colors.grey[500] : Colors.grey[600], // Increased contrast for light mode
                        ),
                      ),
                      Text(
                        "View All",
                        style: TextStyle(
                          fontSize: 12,
                          color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: recentFiles.isEmpty
                      ? Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
                                style: BorderStyle.solid), 
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Text(
                              "No recent files processed",
                              style: TextStyle(
                                fontSize: 14,
                                color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
                              ),
                            ),
                          ),
                        )
                      : Column(
                          children: recentFiles.take(3).map((file) => _buildRecentFileItem(file, isDarkMode)).toList(),
                        ),
                ),
                const SizedBox(height: 100), 
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
          color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildRecentFileItem(ProcessedFile file, bool isDarkMode) {
    // Determine icon and color based on type
    IconData icon;
    Color color;
    if (file.type == 'video') {
      icon = LucideIcons.fileVideo;
      color = const Color(0xFF3B82F6);
    } else if (file.type == 'image') {
      icon = LucideIcons.image;
      color = const Color(0xFFEC4899);
    } else {
      icon = LucideIcons.fileText;
      color = const Color(0xFFEF4444);
    }
    
    // Check if this file is currently processing (retry)
    final activeFile = activeFiles.where((f) => f.id == file.id).firstOrNull;
    final isProcessing = activeFile != null && activeFile.status == FileStatus.processing;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isDarkMode 
          ? Border.all(color: Colors.white.withOpacity(0.05)) 
          : Border.all(color: Colors.grey.shade100), // Very subtle border
        boxShadow: isDarkMode
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: isProcessing 
                ? Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(value: activeFile!.progress / 100, strokeWidth: 2, color: color)))
                : Icon(
                    icon,
                    size: 20,
                    color: color,
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : Colors.blueGrey.shade900, 
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // Show Progress or Size
                if (isProcessing)
                   Row(
                      children: [
                         Expanded(
                           child: LinearProgressIndicator(
                              value: activeFile!.progress / 100,
                              backgroundColor: Colors.grey.withOpacity(0.2),
                              color: color,
                              minHeight: 4,
                              borderRadius: BorderRadius.circular(2),
                           ),
                         ),
                         const SizedBox(width: 8),
                         Text("${activeFile.progress}%", style: TextStyle(fontSize: 10, color: isDarkMode ? Colors.white70 : Colors.black54)),
                      ],
                   )
                else
                  Row(
                    children: [
                      Text(
                        formatBytes(file.originalSize),
                        style: TextStyle(
                          fontSize: 12,
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey[500],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(LucideIcons.arrowRight, size: 12, color: Colors.grey[400]),
                      const SizedBox(width: 6),
                      file.status == 'cancelled' 
                          ? Text("Cancelled", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.redAccent))
                          : Text(
                              formatBytes(file.resultSize),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF10B981),
                              ),
                            ),
                    ],
                  ),
              ],
            ),
          ),
           Row(
            mainAxisSize: MainAxisSize.min,
            children: [
               if (file.status == 'cancelled')
                 ElevatedButton(
                    onPressed: onRetry != null ? () => onRetry!(file) : null,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: isDarkMode ? Colors.indigoAccent.withOpacity(0.2) : Colors.indigo.withOpacity(0.1),
                        foregroundColor: isDarkMode ? Colors.indigoAccent : Colors.indigo,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        elevation: 0,
                    ),
                    child: const Text("Try", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                 )
               else ...[
                   if (onShare != null)
                     IconButton(
                        onPressed: () => onShare!(file),
                        icon: const Icon(LucideIcons.share2),
                        iconSize: 18,
                        style: IconButton.styleFrom(
                          padding: const EdgeInsets.all(8),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[400],
                     ),
                   const SizedBox(width: 8),
                   if (onDownload != null)
                     IconButton(
                       onPressed: () => onDownload!(file),
                       icon: const Icon(LucideIcons.download),
                       iconSize: 18,
                       style: IconButton.styleFrom(
                         backgroundColor: isDarkMode ? Colors.white.withOpacity(0.1) : Colors.grey.shade100,
                         padding: const EdgeInsets.all(8),
                         minimumSize: Size.zero, 
                         tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                       ),
                       color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                     ),
               ]
            ],
          )
        ],
      ),
    );
  }
}
