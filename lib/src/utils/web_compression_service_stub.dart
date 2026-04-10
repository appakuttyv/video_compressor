// Stub for non-web platforms
import '../models/file_model.dart';
import '../models/settings_model.dart';

class WebCompressionService {
  Future<FileModel> compressVideo(FileModel file, AppSettings settings, {Function(int)? onProgress}) async {
    throw UnsupportedError('Web compression only available on web platform');
  }

  Future<FileModel> compressImage(FileModel file, PhotoSettings settings) async {
    throw UnsupportedError('Web compression only available on web platform');
  }
}
