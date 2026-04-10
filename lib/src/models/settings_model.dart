
class AppSettings {
  String mode; // 'smart', 'resolution', 'custom'
  String qualityLevel; // 'low', 'medium', 'high' (Smart Mode)
  String targetResolution; // '1080p', '720p', ... (Resolution Mode)
  double bitrate; // Mbps (Custom Mode)
  int fps; // Custom Mode
  bool removeAudio;
  bool deleteOriginal;

  AppSettings({
    this.mode = 'smart',
    this.qualityLevel = 'medium',
    this.targetResolution = '720p',
    this.bitrate = 2.5,
    this.fps = 30,
    this.removeAudio = false,
    this.deleteOriginal = false,
  });
}

class PhotoSettings {
  double quality; // 0.1 to 1.0
  double resize; // scale factor
  String format; // 'image/jpeg'

  PhotoSettings({
    this.quality = 0.8,
    this.resize = 1.0,
    this.format = 'image/jpeg',
  });
}

class PDFSettings {
  String compression; // 'low', 'medium', 'high'

  PDFSettings({
    this.compression = 'medium',
  });
}
