import 'dart:typed_data';
import 'download_utils.dart';

class DownloadUtilsImpl implements DownloadUtils {
  @override
  Future<void> downloadFile(String fileName, Uint8List bytes) async {
    // No-op or throw on mobile for now (user asked for save to gallery later)
    print('DownloadUtils: Not implemented for mobile, use save to gallery instead.');
  }
}
