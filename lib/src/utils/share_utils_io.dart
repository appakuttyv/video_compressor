import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_compressor/src/models/processed_file.dart';
import 'share_utils.dart';

class ShareUtilsImpl implements ShareUtils {
  @override
  Future<void> shareFile(ProcessedFile file) async {
    String? path = file.savedPath;
    
    if (path == null && file.bytes != null) {
        try {
            final tempDir = await getTemporaryDirectory();
            final tempFile = File('${tempDir.path}/${file.name}');
            await tempFile.writeAsBytes(file.bytes!);
            path = tempFile.path;
        } catch (e) {
            print("Error creating temp file for share: $e");
            return;
        }
    }

    if (path != null) {
       try {
           final xFile = XFile(path);
           await Share.shareXFiles([xFile], text: 'Check out this compressed file!');
       } catch (e) {
           print("Share error: $e");
       }
    } else {
       print("File not found to share");
    }
  }
}
