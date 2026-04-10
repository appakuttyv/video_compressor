
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/file_model.dart';
import '../utils/format_utils.dart';

class ResultScreen extends StatelessWidget {
  final bool isDarkMode;
  final List<FileModel> files;
  final VoidCallback onSaveAll;
  final VoidCallback onDone;

  const ResultScreen({
    super.key,
    required this.isDarkMode,
    required this.files,
    required this.onSaveAll,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    final original = files.fold(0, (sum, f) => sum + f.originalSize);
    final result = files.fold(0, (sum, f) => sum + (f.resultSize > 0 ? f.resultSize : f.originalSize));
    final saved = original - result;

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                      colors: isDarkMode 
                          ? [const Color(0xFF059669), const Color(0xFF14B8A6)] 
                          : [const Color(0xFF34D399), const Color(0xFF5EEAD4)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDarkMode ? const Color(0xFF064E3B).withOpacity(0.4) : const Color(0xFFA7F3D0),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(LucideIcons.checkCircle, color: Colors.white, size: 40),
                ),
                const SizedBox(height: 24),
                Text(
                  'All Done!',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.blueGrey.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your files are ready.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 48),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey.shade50,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('BEFORE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1, color: Colors.grey[500])),
                              Text(formatBytes(original), style: TextStyle(fontSize: 18, color: isDarkMode ? Colors.grey[300] : Colors.blueGrey.shade400)),
                            ],
                          ),
                          Icon(LucideIcons.arrowRight, color: Colors.grey[600]),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('AFTER', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1, color: Colors.grey[500])),
                              Text(formatBytes(result), style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.blueGrey.shade800)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isDarkMode ? const Color(0xFF064E3B).withOpacity(0.5) : const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(LucideIcons.save, size: 20, color: isDarkMode ? const Color(0xFF34D399) : const Color(0xFF059669)),
                            const SizedBox(width: 8),
                            Text(
                              'Saved ${formatBytes(saved)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? const Color(0xFF34D399) : const Color(0xFF059669),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onSaveAll,
            style: ElevatedButton.styleFrom(
              backgroundColor: isDarkMode ? const Color(0xFF4F46E5) : const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 8,
              shadowColor: isDarkMode ? const Color(0xFF312E81).withOpacity(0.5) : const Color(0xFFBFDBFE),
            ),
            child: const Text('Save All', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: onDone,
            style: TextButton.styleFrom(
              minimumSize: const Size(double.infinity, 56),
              foregroundColor: isDarkMode ? Colors.grey[500] : Colors.grey[400],
            ),
            child: const Text('Done', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
