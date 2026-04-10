import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/file_model.dart';
import '../utils/format_utils.dart'; // Ensure formatDuration is here or add it

class ProcessingScreen extends StatefulWidget {
  final bool isDarkMode;
  final List<FileModel> files;
  final VoidCallback onCancel;
  final Function(String) onCancelItem; // New callback

  const ProcessingScreen({
    super.key, 
    required this.isDarkMode, 
    required this.files,
    required this.onCancel,
    required this.onCancelItem,
  });

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen> {
  bool showDetails = false;
  final Map<String, DateTime> _startTimes = {};

  String _calculateETA(FileModel file) {
    if (file.status != FileStatus.processing || file.progress == 0) return 'Calculating...';
    
    // Initialize start time if needed
    if (!_startTimes.containsKey(file.id)) {
      _startTimes[file.id] = DateTime.now();
      return 'Calculating...';
    }

    final startTime = _startTimes[file.id]!;
    final elapsed = DateTime.now().difference(startTime);
    if (elapsed.inSeconds == 0) return 'Calculating...';

    // Calculate speed (bytes per second)
    final processedBytes = file.originalSize * (file.progress / 100);
    final bytesPerSecond = processedBytes / elapsed.inSeconds;
    
    if (bytesPerSecond <= 0) return 'Calculating...';

    // Calculate remaining time
    final remainingBytes = file.originalSize - processedBytes;
    final remainingSeconds = remainingBytes / bytesPerSecond;

    if (remainingSeconds < 60) {
      return '${remainingSeconds.toInt()}s remaining';
    } else {
      final minutes = (remainingSeconds / 60).ceil();
      return '$minutes min remaining';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Logic similar to React
    final activeFile = widget.files.firstWhere(
      (f) => f.status == FileStatus.processing,
      orElse: () => widget.files.firstWhere((f) => f.status == FileStatus.done, orElse: () => widget.files.last),
    );
    
    // Register start time for active file if processing
    if (activeFile.status == FileStatus.processing && !_startTimes.containsKey(activeFile.id)) {
        _startTimes[activeFile.id] = DateTime.now();
    }
    
    // Calculate total progress
    final selectedFiles = widget.files.where((f) => f.selected).toList();
    double totalPercent = 0;
    if (selectedFiles.isNotEmpty) {
      final sum = selectedFiles.fold<double>(0, (prev, f) {
        if (f.status == FileStatus.done) return prev + 100.0;
        if (f.status == FileStatus.processing) return prev + f.progress.toDouble();
        return prev;
      });
      totalPercent = sum / selectedFiles.length;
    }

    return Stack(
      children: [
        // Background Effects
        if (widget.isDarkMode)
          Positioned.fill(
            child: Container(
               color: const Color(0xFF0a0a0a),
               child: Stack(
                 children: [
                    Positioned(
                      top: MediaQuery.of(context).size.height / 2 - 150,
                      left: MediaQuery.of(context).size.width / 2 - 150,
                      child: Container(
                        width: 300, height: 300,
                        decoration: BoxDecoration(
                           color: Colors.indigo.shade900.withOpacity(0.2),
                           borderRadius: BorderRadius.circular(150),
                           boxShadow: [BoxShadow(color: Colors.indigo.shade600.withOpacity(0.2), blurRadius: 100, spreadRadius: 50)]
                        ),
                      ),
                    )
                 ],
               ),
            ),
          ),

        // Main Content
        AnimatedOpacity(
          opacity: showDetails ? 0.0 : 1.0,
          duration: const Duration(milliseconds: 300),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                 SizedBox(
                   width: 240, height: 240,
                   child: Stack(
                     fit: StackFit.expand,
                     children: [
                        CircularProgressIndicator(
                          value: 1.0,
                          strokeWidth: 12,
                          color: widget.isDarkMode ? Colors.white10 : Colors.grey.shade200,
                        ),
                        CircularProgressIndicator(
                           value: totalPercent / 100,
                           strokeWidth: 12,
                           color: widget.isDarkMode ? const Color(0xFF6366F1) : const Color(0xFF2563EB),
                           strokeCap: StrokeCap.round,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                             Text(
                               '${totalPercent.toInt()}%',
                               style: TextStyle(
                                 fontSize: 56,
                                 fontWeight: FontWeight.bold,
                                 color: widget.isDarkMode ? Colors.white : Colors.blueGrey.shade800,
                               ),
                             ),
                             const SizedBox(height: 8),
                             if (activeFile.status == FileStatus.processing)
                               Text(
                                 _calculateETA(activeFile), // Show ETA here
                                 style: TextStyle(
                                   fontSize: 14,
                                   color: widget.isDarkMode ? Colors.indigoAccent : Colors.blue,
                                   fontWeight: FontWeight.w500,
                                 ),
                               ),
                          ],
                        )
                     ],
                   ),
                 ),
                 const SizedBox(height: 48),
                 Text(
                   activeFile.status == FileStatus.processing ? 'Compressing...' : 'Finishing up',
                   style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: widget.isDarkMode ? Colors.white : Colors.black87),
                 ),
                 const SizedBox(height: 8),
                 Text(
                    activeFile.status == FileStatus.processing
                    ? '${formatBytes((activeFile.originalSize * activeFile.progress / 100).toInt())} / ${formatBytes(activeFile.originalSize)}'
                    : '',
                    style: TextStyle(fontFamily: 'monospace', color: widget.isDarkMode ? Colors.indigoAccent : Colors.blue),
                 ),
                 const SizedBox(height: 8),
                 Text(activeFile.name, style: TextStyle(color: Colors.grey, fontSize: 12)),
                 const SizedBox(height: 48),
                 Row(
                   mainAxisAlignment: MainAxisAlignment.center,
                   children: [
                     ElevatedButton.icon(
                       icon: const Icon(LucideIcons.list, size: 18),
                       label: const Text('View Details'),
                       style: ElevatedButton.styleFrom(
                         backgroundColor: widget.isDarkMode ? Colors.white10 : Colors.grey.shade200,
                         foregroundColor: widget.isDarkMode ? Colors.white : Colors.black87,
                         padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                       ),
                       onPressed: () => setState(() => showDetails = true),
                     ),
                     const SizedBox(width: 16),
                     ElevatedButton.icon(
                        icon: const Icon(LucideIcons.stopCircle, size: 18),
                        label: const Text('Cancel'),
                        style: ElevatedButton.styleFrom(
                           backgroundColor: Colors.red.withOpacity(0.1),
                           foregroundColor: Colors.red,
                           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                           elevation: 0,
                        ),
                        onPressed: widget.onCancel,
                     )
                   ],
                 )
              ],
            ),
          ),
        ),

        // Details Overlay
        AnimatedSlide(
           offset: showDetails ? Offset.zero : const Offset(0, 1),
           duration: const Duration(milliseconds: 300),
           curve: Curves.easeInOut,
           child: Container(
             height: MediaQuery.of(context).size.height, // Full height
             color: widget.isDarkMode ? const Color(0xFF121212) : Colors.white,
             child: Column(
               children: [
                 Padding(
                   padding: const EdgeInsets.all(24),
                   child: Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       Text('Queue Details', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: widget.isDarkMode ? Colors.white : Colors.black)),
                       IconButton(
                         icon: const Icon(LucideIcons.x),
                         onPressed: () => setState(() => showDetails = false),
                         style: IconButton.styleFrom(backgroundColor: widget.isDarkMode ? Colors.white10 : Colors.grey.shade200),
                         color: widget.isDarkMode ? Colors.white : Colors.black,
                       )
                     ],
                   ),
                 ),
                 Expanded(
                   child: ListView(
                     padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24), // Added bottom padding
                     children: [
                        ...widget.files.where((f) => f.selected && (f.status == FileStatus.idle || f.status == FileStatus.processing)).map((f) => 
                           Padding(
                             padding: const EdgeInsets.only(bottom: 12),
                             child: Container(
                               padding: const EdgeInsets.all(16),
                               decoration: BoxDecoration(
                                  // Highlight actively processing file
                                  color: f.status == FileStatus.processing 
                                      ? (widget.isDarkMode ? Colors.indigo.withOpacity(0.1) : Colors.indigo.withOpacity(0.05))
                                      : null,
                                  border: Border.all(
                                      color: f.status == FileStatus.processing 
                                          ? Colors.indigo.withOpacity(0.3) 
                                          : Colors.grey.withOpacity(0.2)
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                               ),
                               child: Row(
                                  children: [
                                     // Icon or Spinner
                                     Container(
                                         width: 40, height: 40,
                                         decoration: BoxDecoration(
                                             color: widget.isDarkMode ? Colors.white10 : Colors.grey.shade100,
                                             borderRadius: BorderRadius.circular(8),
                                         ),
                                         child: f.status == FileStatus.processing
                                             ? Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.indigoAccent, value: f.progress / 100)))
                                             : Icon(LucideIcons.clock, size: 20, color: Colors.grey),
                                     ),
                                     const SizedBox(width: 12),
                                     Expanded(
                                       child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                             Text(
                                                f.name, 
                                                maxLines: 1, 
                                                overflow: TextOverflow.ellipsis, 
                                                style: TextStyle(fontWeight: FontWeight.w500, color: widget.isDarkMode ? Colors.white : Colors.black87)
                                             ),
                                             const SizedBox(height: 4),
                                             if (f.status == FileStatus.processing)
                                                Text(
                                                  _calculateETA(f), 
                                                  style: TextStyle(fontSize: 12, color: Colors.indigoAccent, fontWeight: FontWeight.bold)
                                                )
                                             else
                                                Text('Waiting...', style: TextStyle(color: Colors.grey.withOpacity(0.7), fontSize: 12)),
                                          ],
                                       ),
                                     ),
                                     // Cancel Button
                                     IconButton(
                                         icon: const Icon(LucideIcons.xCircle, size: 20),
                                         color: Colors.redAccent,
                                         onPressed: () => widget.onCancelItem(f.id),
                                         tooltip: "Cancel",
                                     )
                                  ],
                               ),
                             ),
                           )
                        ),

                        ...widget.files.where((f) => f.status == FileStatus.done && f.selected).map((f) => 
                           Padding(
                             padding: const EdgeInsets.only(bottom: 12),
                             child: Container(
                               padding: const EdgeInsets.all(16),
                               decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.05),
                                  border: Border.all(color: Colors.green.withOpacity(0.2)),
                                  borderRadius: BorderRadius.circular(16),
                               ),
                               child: Row(
                                  children: [
                                     const Icon(LucideIcons.checkCircle, size: 20, color: Colors.green),
                                     const SizedBox(width: 12),
                                     Expanded(
                                       child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                             Text(
                                                f.name, 
                                                maxLines: 1, 
                                                overflow: TextOverflow.ellipsis, 
                                                style: TextStyle(fontWeight: FontWeight.w500, color: widget.isDarkMode ? Colors.white : Colors.black87)
                                             ),
                                             // Size info for completed files
                                             Row(
                                                children: [
                                                   Text(formatBytes(f.originalSize), style: TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey, fontSize: 10)),
                                                   const SizedBox(width: 4),
                                                   const Icon(LucideIcons.arrowRight, size: 8, color: Colors.grey),
                                                   const SizedBox(width: 4),
                                                   Text(formatBytes(f.resultSize), style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 10)),
                                                ],
                                             )
                                          ],
                                       ),
                                     )
                                  ],
                               ),
                             ),
                           )
                        ),
                        
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: widget.onCancel,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.withOpacity(0.1),
                            foregroundColor: Colors.red,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 0,
                          ),
                          child: const Text('Cancel All Remaining', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                     ],
                   ),
                 )
               ],
             ),
           )
        )
      ],
    );
  }
}
