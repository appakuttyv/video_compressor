import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:ui';
import '../models/file_model.dart';
import '../models/processed_file.dart';
import '../utils/format_utils.dart';
import '../components/header.dart';

class FileManagerScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;
  final VoidCallback onBack;
  final List<ProcessedFile> files;
  final Function(String) onDelete;

  const FileManagerScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
    required this.onBack,
    required this.files,
    required this.onDelete,
  });

  @override
  State<FileManagerScreen> createState() => _FileManagerScreenState();
}

class _FileManagerScreenState extends State<FileManagerScreen> {
  MediaType activeTab = MediaType.video;

  String _getTabLabel(String type) {
    if (type == 'video') return 'Videos';
    if (type == 'image') return 'Photos';
    return 'PDFs';
  }

  IconData _getTabIcon(String type) {
    if (type == 'video') return LucideIcons.fileVideo;
    if (type == 'image') return LucideIcons.image;
    return LucideIcons.fileText;
  }

  Color _getTabColor(String type) {
    if (type == 'video') return Colors.blue;
    if (type == 'image') return Colors.pink;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final activeTabString = activeTab == MediaType.video ? 'video' : activeTab == MediaType.image ? 'image' : 'pdf';
    final filteredFiles = widget.files.where((f) => f.type == activeTabString).toList();
    final totalOriginal = filteredFiles.fold(0, (sum, f) => sum + f.originalSize);
    final totalCompressed = filteredFiles.fold(0, (sum, f) => sum + f.resultSize);
    final totalSaved = totalOriginal - totalCompressed;

    return Column(
      children: [
        Header(
          title: 'File Manager',
          isDarkMode: widget.isDarkMode,
          onThemeToggle: widget.onThemeToggle,
          showBack: true,
          onBack: widget.onBack,
        ),
        
        // Savings Card
        Container(
           margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
           padding: const EdgeInsets.all(24),
           decoration: BoxDecoration(
             borderRadius: BorderRadius.circular(32),
             gradient: LinearGradient(
               begin: Alignment.bottomLeft,
               end: Alignment.topRight,
               colors: widget.isDarkMode
                 ? [const Color(0xFF065F46), const Color(0xFF0F766E)] // Emerald-800 to Teal-700
                 : [const Color(0xFF10B981), const Color(0xFF2DD4BF)], // Emerald-500 to Teal-400
             ),
             boxShadow: [
               BoxShadow(
                 color: (widget.isDarkMode ? const Color(0xFF065F46) : const Color(0xFF10B981)).withOpacity(0.3),
                 blurRadius: 20,
                 offset: const Offset(0, 10),
               ),
             ],
           ),
           child: Stack(
             children: [
               Positioned(
                 top: -20,
                 right: -20,
                 child: Container(
                    width: 128, height: 128,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container()
                      ),
                    )
                 ),
               ),
               Column(
                 crossAxisAlignment: CrossAxisAlignment.stretch,
                 children: [
                   Row(
                     children: [
                       Icon(LucideIcons.sparkles, size: 16, color: Colors.white.withOpacity(0.8)),
                       const SizedBox(width: 8),
                       Text(
                         '${activeTab == MediaType.video ? 'Video' : activeTab == MediaType.image ? 'Photo' : 'PDF'} Savings',
                         style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                         ),
                       ),
                     ],
                   ),
                   const SizedBox(height: 16),
                   Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     crossAxisAlignment: CrossAxisAlignment.end,
                     children: [
                       Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                            Text(
                              formatBytes(totalSaved),
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Space Saved',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.6),
                              ),
                            ),
                         ],
                       ),
                       Column(
                         crossAxisAlignment: CrossAxisAlignment.end,
                         children: [
                            Text(
                              formatBytes(totalOriginal),
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                            Text(
                              'Total Uploaded',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.6),
                              ),
                            ),
                         ],
                       ),
                     ],
                   ),
                   const SizedBox(height: 16),
                   // Progress bar
                   Container(
                     height: 6,
                     decoration: BoxDecoration(
                       color: Colors.black.withOpacity(0.2),
                       borderRadius: BorderRadius.circular(3),
                     ),
                     child: Row(
                       children: [
                         Expanded(
                           flex: (totalCompressed > 0 ? totalCompressed : 1),
                           child: Container(
                             decoration: BoxDecoration(
                               color: Colors.white.withOpacity(0.8),
                               borderRadius: BorderRadius.circular(3),
                             ),
                           ),
                         ),
                         Expanded(
                           flex: (totalSaved > 0 ? totalSaved : 1),
                           child: const SizedBox(),
                         ),
                       ],
                     ),
                   ),
                   const SizedBox(height: 8),
                   Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       Text(
                         'Converted: ${formatBytes(totalCompressed)}',
                         style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 10),
                       ),
                       Text(
                         'Ratio: ${totalOriginal > 0 ? ((1 - totalCompressed / totalOriginal) * 100).round() : 0}%',
                         style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 10),
                       ),
                     ],
                   ),
                 ],
               ),
             ],
           ),
        ),

        // Tabs
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: widget.isDarkMode ? Colors.black.withOpacity(0.3) : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: MediaType.values.map((type) {
                 final isActive = activeTab == type;
                 final typeStr = type == MediaType.video ? 'video' : type == MediaType.image ? 'image' : 'pdf';
                 final color = _getTabColor(typeStr);
                 return Expanded(
                   child: GestureDetector(
                     onTap: () => setState(() => activeTab = type),
                     child: AnimatedContainer(
                       duration: const Duration(milliseconds: 200),
                       padding: const EdgeInsets.symmetric(vertical: 12),
                       decoration: BoxDecoration(
                         color: isActive 
                           ? (widget.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white)
                           : Colors.transparent,
                         borderRadius: BorderRadius.circular(12),
                         boxShadow: isActive ? [
                           BoxShadow(
                             color: Colors.black.withOpacity(0.1),
                             blurRadius: 4,
                             offset: const Offset(0, 2),
                           )
                         ] : [],
                       ),
                       child: Column(
                         children: [
                           Icon(
                             _getTabIcon(typeStr),
                             size: 18,
                             color: isActive ? color : Colors.grey,
                           ),
                           const SizedBox(height: 4),
                           Text(
                             _getTabLabel(typeStr),
                             style: TextStyle(
                               fontSize: 10,
                               fontWeight: FontWeight.bold,
                               color: isActive 
                                 ? (widget.isDarkMode ? Colors.white : Colors.black87)
                                 : Colors.grey,
                             ),
                           ),
                         ],
                       ),
                     ),
                   ),
                 );
              }).toList(),
            ),
          ),
        ),

        // List
        Expanded(
          child: filteredFiles.isEmpty 
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.folderOpen, size: 48, color: Colors.grey.withOpacity(0.2)),
                  const SizedBox(height: 16),
                  Text('No files in this folder', style: TextStyle(color: Colors.grey.withOpacity(0.5))),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              itemCount: filteredFiles.length,
              itemBuilder: (context, index) {
                final file = filteredFiles[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    padding: const EdgeInsets.all(12), // reduced padding
                    decoration: BoxDecoration(
                      color: widget.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: widget.isDarkMode ? null : Border.all(color: Colors.grey.shade100),
                      boxShadow: widget.isDarkMode ? [] : [
                        BoxShadow(
                          color: Colors.grey.shade100,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48, height: 48,
                          decoration: BoxDecoration(
                            color: widget.isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _getTabIcon(file.type),
                            size: 20,
                            color: _getTabColor(file.type),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                file.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: widget.isDarkMode ? Colors.white : Colors.black87,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    formatBytes(file.originalSize),
                                    style: TextStyle(
                                      decoration: TextDecoration.lineThrough,
                                      color: Colors.grey.withOpacity(0.7),
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(LucideIcons.arrowRight, size: 10, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(
                                    formatBytes(file.resultSize),
                                    style: const TextStyle(
                                      color: Colors.green, // Emerald-500
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(LucideIcons.share2, size: 18),
                              color: Colors.grey,
                              onPressed: () {
                                // Share simulation
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Sharing ${file.name}...')),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(LucideIcons.trash2, size: 18),
                              color: Colors.grey, // Hover red effect not easy in mobile, sticky to grey/red
                              onPressed: () => widget.onDelete(file.id),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ),
      ],
    );
  }
}
