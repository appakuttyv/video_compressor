import 'package:video_compressor/src/models/processed_file.dart';

abstract class ShareUtils {
  Future<void> shareFile(ProcessedFile file);
}
