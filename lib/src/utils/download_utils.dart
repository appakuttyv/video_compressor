import 'dart:typed_data';

abstract class DownloadUtils {
  Future<void> downloadFile(String fileName, Uint8List bytes);
}
