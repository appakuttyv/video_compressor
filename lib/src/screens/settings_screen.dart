
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/settings_model.dart';
import '../models/file_model.dart';
import '../utils/format_utils.dart';

class SettingsScreen extends StatelessWidget {
  final bool isDarkMode;
  final MediaType activeMediaType;
  final AppSettings settings;
  final PhotoSettings photoSettings;
  final Function(AppSettings) onUpdateSettings;
  final Function(PhotoSettings) onUpdatePhotoSettings;
  final VoidCallback onStartProcessing;
  final VoidCallback onCancel;
  final List<FileModel> selectedFiles;

  final PDFSettings? pdfSettings;
  final Function(PDFSettings)? onUpdatePDFSettings;

  const SettingsScreen({
    super.key,
    required this.isDarkMode,
    required this.activeMediaType,
    required this.settings,
    required this.photoSettings,
    this.pdfSettings,
    this.onUpdatePDFSettings,
    required this.onUpdateSettings,
    required this.onUpdatePhotoSettings,
    required this.onStartProcessing,
    required this.onCancel,
    required this.selectedFiles,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              GestureDetector(
                onTap: onCancel,
                child: Container(color: Colors.black54),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.85,
                  ),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 48,
                            height: 6,
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          activeMediaType == MediaType.video ? 'Video Settings' : 'Photo Settings',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.blueGrey.shade800,
                          ),
                        ),
                        const SizedBox(height: 24),
                        if (activeMediaType == MediaType.image) 
                          _buildPhotoSettings(context) 
                        else if (activeMediaType == MediaType.pdf && pdfSettings != null && onUpdatePDFSettings != null)
                          _buildPDFSettings(context)
                        else 
                          _buildVideoSettings(context),
                        const SizedBox(height: 32),
                        _buildEstimationCard(context),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: onStartProcessing,
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
                          child: const Text('Start Processing', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: onCancel,
                          style: TextButton.styleFrom(
                            minimumSize: const Size(double.infinity, 56),
                            foregroundColor: isDarkMode ? Colors.grey[500] : Colors.grey[400],
                          ),
                          child: const Text('Cancel', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoSettings(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Quality'),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 8,
            activeTrackColor: isDarkMode ? const Color(0xFF6366F1) : Colors.blue,
            inactiveTrackColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
            thumbColor: Colors.white,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
            overlayColor: const Color(0xFF6366F1).withOpacity(0.2),
          ),
          child: Slider(
            min: 0.1,
            max: 1.0,
            value: photoSettings.quality,
            onChanged: (val) => onUpdatePhotoSettings(PhotoSettings(
              quality: val,
              resize: photoSettings.resize,
              format: photoSettings.format,
            )),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Low', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
            Text('${(photoSettings.quality * 100).toInt()}%', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
            Text('High', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
          ],
        ),
        const SizedBox(height: 24),
        _buildLabel('Resize'),
        Row(
          children: [1.0, 0.75, 0.5].map((scale) {
            final isSelected = photoSettings.resize == scale;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: GestureDetector(
                  onTap: () => onUpdatePhotoSettings(PhotoSettings(
                    quality: photoSettings.quality,
                    resize: scale,
                    format: photoSettings.format,
                  )),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isDarkMode ? const Color(0xFF312E81).withOpacity(0.5) : const Color(0xFFEFF6FF))
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? (isDarkMode ? const Color(0xFF6366F1) : Colors.blue)
                            : (isDarkMode ? Colors.grey[800]! : Colors.grey[300]!),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '${(scale * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? (isDarkMode ? const Color(0xFF818CF8) : Colors.blue)
                              : (isDarkMode ? Colors.grey[400] : Colors.grey[500]),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildVideoSettings(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.black.withOpacity(0.3) : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: ['smart', 'resolution', 'custom'].map((mode) {
              final isSelected = settings.mode == mode;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onUpdateSettings(_updateMode(mode)),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isDarkMode ? const Color(0xFF4F46E5) : Colors.white)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: isSelected && !isDarkMode
                          ? [BoxShadow(color: Colors.grey.shade300, blurRadius: 4, offset: const Offset(0, 2))]
                          : [],
                    ),
                    child: Center(
                      child: Text(
                        mode.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? (isDarkMode ? Colors.white : Colors.blue)
                              : Colors.grey[500],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 24),
        if (settings.mode == 'smart') _buildSmartMode(),
        if (settings.mode == 'resolution') _buildResolutionMode(),
        if (settings.mode == 'custom') _buildCustomMode(context),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.black.withOpacity(0.2) : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(LucideIcons.scissors, size: 20, color: isDarkMode ? Colors.grey[400] : Colors.grey[500]),
                  const SizedBox(width: 12),
                  Text(
                    'Remove Audio',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: isDarkMode ? Colors.grey[300] : Colors.blueGrey.shade700,
                    ),
                  ),
                ],
              ),
              Switch(
                value: settings.removeAudio,
                onChanged: (val) {
                  settings.removeAudio = val;
                  onUpdateSettings(settings);
                },
                activeColor: const Color(0xFF6366F1),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSmartMode() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Compression Level'),
        Row(
          children: ['high', 'medium', 'low'].map((level) {
            final isSelected = settings.qualityLevel == level;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: GestureDetector(
                  onTap: () {
                    settings.qualityLevel = level;
                    onUpdateSettings(settings);
                  },
                  child: Container(
                    height: 80,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isDarkMode ? const Color(0xFF312E81).withOpacity(0.5) : const Color(0xFFEFF6FF))
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? (isDarkMode ? const Color(0xFF6366F1) : Colors.blue)
                            : (isDarkMode ? Colors.grey[800]! : Colors.grey[300]!),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          LucideIcons.zap,
                          size: 20,
                          color: isSelected
                              ? (isDarkMode ? const Color(0xFF818CF8) : Colors.blue)
                              : Colors.grey[500],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          level == 'high' ? 'High Quality' : level == 'medium' ? 'Balanced' : 'Max Saver',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                             color: isSelected
                              ? (isDarkMode ? const Color(0xFF818CF8) : Colors.blue)
                              : Colors.grey[500],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildResolutionMode() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Target Resolution'),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 2.5,
          children: ['1080p', '720p', '480p', '360p'].map((res) {
            final isSelected = settings.targetResolution == res;
            return GestureDetector(
              onTap: () {
                settings.targetResolution = res;
                onUpdateSettings(settings);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDarkMode ? const Color(0xFF312E81).withOpacity(0.5) : const Color(0xFFEFF6FF))
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? (isDarkMode ? const Color(0xFF6366F1) : Colors.blue)
                        : (isDarkMode ? Colors.grey[800]! : Colors.grey[300]!),
                  ),
                ),
                child: Center(
                  child: Text(
                    res,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? (isDarkMode ? const Color(0xFF818CF8) : Colors.blue)
                          : (isDarkMode ? Colors.grey[400] : Colors.grey[500]),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCustomMode(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildLabel('Bitrate'),
            Text(
              '${settings.bitrate} Mbps',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF818CF8),
                fontSize: 12,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 6,
            activeTrackColor: isDarkMode ? const Color(0xFF6366F1) : Colors.blue,
            inactiveTrackColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
            thumbColor: Colors.white,
            overlayColor: const Color(0xFF6366F1).withOpacity(0.2),
          ),
          child: Slider(
            min: 0.5,
            max: 8.0,
            divisions: 15,
            value: settings.bitrate,
            onChanged: (val) {
              settings.bitrate = val;
              onUpdateSettings(settings);
            },
          ),
        ),
        const SizedBox(height: 16),
        _buildLabel('Frame Rate (FPS)'),
        Row(
          children: [60, 30, 24, 15].map((fps) {
            final isSelected = settings.fps == fps;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: GestureDetector(
                  onTap: () {
                    settings.fps = fps;
                    onUpdateSettings(settings);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isDarkMode ? const Color(0xFF312E81).withOpacity(0.5) : const Color(0xFFEFF6FF))
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? (isDarkMode ? const Color(0xFF6366F1) : Colors.blue)
                            : (isDarkMode ? Colors.grey[800]! : Colors.grey[300]!),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '$fps',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? (isDarkMode ? const Color(0xFF818CF8) : Colors.blue)
                              : (isDarkMode ? Colors.grey[400] : Colors.grey[500]),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
          color: Colors.grey[500],
        ),
      ),
    );
  }

  Widget _buildPDFSettings(BuildContext context) {
      return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              _buildLabel("Compression Strength"),
              Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                      color: isDarkMode ? Colors.black.withOpacity(0.3) : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16)
                  ),
                  child: Row(
                      children: ["extreme", "recommended", "less"].map((mode) {
                          final isSelected = pdfSettings?.compression == mode;
                          return Expanded(
                              child: GestureDetector(
                                  onTap: () => onUpdatePDFSettings?.call(PDFSettings(compression: mode)),
                                  child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      decoration: BoxDecoration(
                                          color: isSelected ? (isDarkMode ? const Color(0xFFEF4444) : Colors.white) : Colors.transparent,
                                          borderRadius: BorderRadius.circular(12),
                                          boxShadow: isSelected && !isDarkMode ? [BoxShadow(color: Colors.grey.shade300, blurRadius: 4, offset: const Offset(0, 2))] : []
                                      ),
                                      child: Column(
                                          children: [
                                              Text(
                                                  mode == "extreme" ? "Extreme" : mode == "recommended" ? "Medium" : "Low",
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 12,
                                                      color: isSelected ? (isDarkMode ? Colors.white : Colors.red) : Colors.grey
                                                  )
                                              ),
                                              Text(
                                                  mode == "extreme" ? "< 20%" : mode == "recommended" ? "~50%" : "~80%",
                                                  style: TextStyle(
                                                      fontSize: 10,
                                                      color: isSelected ? (isDarkMode ? Colors.white70 : Colors.red.withOpacity(0.7)) : Colors.grey.withOpacity(0.5)
                                                  )
                                              )
                                          ],
                                      )
                                  )
                              )
                          );
                      }).toList()
                  )
              ),
              const SizedBox(height: 24),
              Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: isDarkMode ? Colors.red.withOpacity(0.1) : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isDarkMode ? Colors.red.withOpacity(0.3) : Colors.red.shade100)
                  ),
                  child: Row(
                      children: [
                          Icon(LucideIcons.alertCircle, color: isDarkMode ? Colors.red.shade300 : Colors.red, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                              child: Text(
                                  pdfSettings?.compression == "extreme" 
                                  ? "May reduce quality significantly. Best for text-only docs."
                                  : "Balanced compression for most documents.",
                                  style: TextStyle(
                                      color: isDarkMode ? Colors.red.shade200 : Colors.red.shade800,
                                      fontSize: 12
                                  )
                              )
                          )
                      ]
                  )
              )
          ]
      );
  }

  Widget _buildEstimationCard(BuildContext context) {
    // Basic estimation logic
    String sizeText = "Calculating...";
    String resText = "Auto";

    if (activeMediaType == MediaType.image) {
      if (selectedFiles.isNotEmpty) {
        double est = 0;
        for(var f in selectedFiles) {
           est += f.originalSize * photoSettings.quality * 0.2; // roughly
        }
        sizeText = formatBytes(est.toInt());
        resText = "${(photoSettings.quality * 100).toInt()}% Quality";
      } else {
        sizeText = "0 MB";
        resText = "N/A";
      }
    } else if (activeMediaType == MediaType.pdf) {
         if (selectedFiles.isNotEmpty) {
             double factor = pdfSettings?.compression == "extreme" ? 0.2 : pdfSettings?.compression == "recommended" ? 0.5 : 0.8;
             double est = 0;
             for(var f in selectedFiles) {
                 est += f.originalSize * factor;
             }
             sizeText = formatBytes(est.toInt());
             resText = pdfSettings?.compression == "extreme" ? "Low Quality" : "Standard";
         } else {
             sizeText = "0 MB";
             resText = "N/A";
         }
    } else {
       // Video logic
       double bitrate = 2.5; 
       if (settings.mode == 'smart') {
         bitrate = settings.qualityLevel == 'low' ? 1.0 : settings.qualityLevel == 'medium' ? 2.5 : 5.0;
         resText = 'Auto';
       } else if (settings.mode == 'resolution') {
          // approx bitrate for res
          if (settings.targetResolution == '1080p') bitrate = 4.0;
          if (settings.targetResolution == '720p') bitrate = 2.0;
          if (settings.targetResolution == '480p') bitrate = 0.8;
       } else {
         bitrate = settings.bitrate;
         resText = "${settings.bitrate} Mbps";
       }
       
       // Calculate size based on duration if available
       // For now, assume average duration or use mocked meta if available
       // Since we don't have video_compress logic in meta yet, use a rough estimate if meta missing
       
       double totalDuration = 0;
       for (var f in selectedFiles) {
         totalDuration += f.meta.duration > 0 ? f.meta.duration : 60; // default 60s if unknown
       }

       if (totalDuration > 0) {
          double bits = bitrate * 1000000 * totalDuration;
          double bytes = bits / 8;
          sizeText = formatBytes(bytes.toInt());
       } else {
         sizeText = "0 MB";
       }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.black.withOpacity(0.4) : const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? const Color(0xFF6366F1).withOpacity(0.3) : const Color(0xFFBFDBFE),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(LucideIcons.monitor, size: 20, color: const Color(0xFF818CF8)),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ESTIMATED OUTPUT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[500])),
                  Text(
                    sizeText,
                    style: TextStyle(
                      fontFamily: 'Unknown Monospace',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.blueGrey.shade800,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('RES/QUALITY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[500])),
              Text(
                resText,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDarkMode ? Colors.grey[300] : Colors.blueGrey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  AppSettings _updateMode(String mode) {
    settings.mode = mode;
    return settings;
  }
}
