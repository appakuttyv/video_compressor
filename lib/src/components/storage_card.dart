import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:ui';
import '../utils/format_utils.dart';

class StorageCard extends StatelessWidget {
  final int used;
  final int quota;
  final int videoStorage;
  final int photoStorage;
  final bool isDarkMode;

  final int docStorage;

  const StorageCard({
    super.key,
    required this.used,
    required this.quota,
    required this.videoStorage,
    required this.photoStorage,
    this.docStorage = 0,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final double percentage = quota > 0 ? (used / quota).clamp(0.0, 1.0) : 0.0;
    final int percentageInt = (percentage * 100).toInt();

    return Container(
      margin: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? [const Color(0xFF4F46E5), const Color(0xFF7E22CE)] // Indigo-600 to Purple-700
              : [const Color(0xFF3B82F6), const Color(0xFF22D3EE)], // Blue-500 to Cyan-400
        ),
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? const Color(0xFF581C87).withOpacity(0.3) : const Color(0xFFBFDBFE),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                  child: BackdropFilter(
                      filter:  ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container()
                  )
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       Row(
                          children: [
                              Icon(LucideIcons.hardDrive, size: 14, color: Colors.white.withOpacity(0.8)),
                              const SizedBox(width: 8),
                              Text(
                                'System Storage',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                          ]
                       ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '$percentageInt.0', // Fixed to match screenshot .0 logic if desired, or just int
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '% Used',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        formatBytes(quota - used),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'Free Space',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: percentage,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12)
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                       _buildBreakdownItem(color: Colors.blue.shade300, label: "Vid", value: formatBytes(videoStorage)),
                       _buildBreakdownItem(color: Colors.pink.shade300, label: "Pic", value: formatBytes(photoStorage)),
                       _buildBreakdownItem(color: Colors.red.shade300, label: "Doc", value: formatBytes(docStorage)),
                    ],
                )
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownItem({required Color color, required String label, required String value}) {
      return Row(
          children: [
              Container(
                  width: 8, height: 8,
                  decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: color.withOpacity(0.8), blurRadius: 8)]
                  ),
              ),
              const SizedBox(width: 8),
              Text(
                  "$label: $value",
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 10, // Small text as in React code "text-xs"
                      fontWeight: FontWeight.w500
                  )
              )
          ]
      );
  }
}
