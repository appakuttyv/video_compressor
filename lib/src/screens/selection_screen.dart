
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../components/header.dart';
import '../models/file_model.dart';
import '../utils/format_utils.dart';

class SelectionScreen extends StatelessWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;
  final VoidCallback onBack;
  final MediaType activeMediaType;
  final List<FileModel> files;
  final Function(String) onToggleSelect;
  final VoidCallback onSelectAll;
  final VoidCallback onContinue;

  const SelectionScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
    required this.onBack,
    required this.activeMediaType,
    required this.files,
    required this.onToggleSelect,
    required this.onSelectAll,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final allSelected = files.isNotEmpty && files.every((f) => f.selected);
    final selectedSize = files.where((f) => f.selected).fold(0, (sum, f) => sum + f.originalSize);
    final selectedCount = files.where((f) => f.selected).length;

    return Column(
      children: [
        Header(
          title: activeMediaType == MediaType.video 
              ? 'Select Videos' 
              : activeMediaType == MediaType.image 
                  ? 'Select Photos' 
                  : 'Select PDFs',
          showBack: true,
          onBack: onBack,
          isDarkMode: isDarkMode,
          onThemeToggle: onThemeToggle,
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            itemCount: files.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final file = files[index];
              return GestureDetector(
                onTap: () => onToggleSelect(file.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: file.selected
                        ? (isDarkMode ? const Color(0xFF312E81).withOpacity(0.3) : const Color(0xFFEFF6FF))
                        : (isDarkMode ? const Color(0xFF1E1E1E) : Colors.white),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: file.selected
                          ? (isDarkMode ? const Color(0xFF6366F1).withOpacity(0.5) : const Color(0xFFBFDBFE))
                          : (isDarkMode ? Colors.transparent : Colors.grey.shade100),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: isDarkMode ? Colors.black.withOpacity(0.3) : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          activeMediaType == MediaType.video 
                              ? LucideIcons.fileVideo 
                              : activeMediaType == MediaType.image 
                                  ? LucideIcons.image
                                  : LucideIcons.fileText,
                          size: 20,
                          color: isDarkMode ? Colors.grey[400] : Colors.grey[500],
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
                                fontWeight: FontWeight.w500,
                                color: isDarkMode ? Colors.grey[200] : Colors.blueGrey.shade700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              formatBytes(file.originalSize),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: file.selected
                              ? (isDarkMode ? const Color(0xFF6366F1) : Colors.blue)
                              : Colors.transparent,
                          border: Border.all(
                            color: file.selected
                                ? (isDarkMode ? const Color(0xFF6366F1) : Colors.blue)
                                : Colors.grey,
                            width: 2,
                          ),
                        ),
                        child: file.selected
                            ? const Icon(LucideIcons.check, size: 14, color: Colors.white)
                            : null,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: onSelectAll,
                        child: Text(
                          allSelected ? 'Unselect All' : 'Select All',
                          style: const TextStyle(
                            color: Color(0xFF818CF8),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$selectedCount selected',
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                  Text(
                    formatBytes(selectedSize),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.blueGrey.shade800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: selectedCount > 0 ? onContinue : null,
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
                child: const Text('Continue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
