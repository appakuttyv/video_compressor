import 'package:video_compressor/src/models/processed_file.dart';
import 'share_utils.dart';

// Web implementation
class ShareUtilsImpl implements ShareUtils {
  @override
  Future<void> shareFile(ProcessedFile file) async {
    // Web sharing is limited. 
    // We could use Web Share API data if bytes are present, 
    // but typically we just notify or do nothing.
    print("Sharing not supported on web in this context.");
  }
}
