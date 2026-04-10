import 'dart:html' as html;
import 'dart:typed_data';
import 'dart:async';
import 'dart:convert'; // For base64
import '../models/file_model.dart';
import '../models/settings_model.dart';

class WebCompressionService {
  Future<FileModel> compressVideo(FileModel file, AppSettings settings, {Function(int)? onProgress}) async {
    if (file.bytes == null) {
      return file.copyWith(status: FileStatus.error);
    }

    try {
      final blob = html.Blob([file.bytes!]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final video = html.VideoElement()
        ..src = url
        ..muted = true
        ..crossOrigin = 'anonymous';
      
      video.setAttribute('playsinline', 'true');

      await video.onLoadedMetadata.first;

      int targetW = video.videoWidth;
      int targetH = video.videoHeight;
      int targetBitrate = 2500000;
      int targetFPS = 30;

      if (settings.mode == 'smart') {
        if (settings.qualityLevel == 'low') targetBitrate = 1000000;
        else if (settings.qualityLevel == 'medium') targetBitrate = 2500000;
        else targetBitrate = 5000000;
        
        if (targetW > 1920) {
          final ratio = 1920 / targetW;
          targetW = 1920;
          targetH = (targetH * ratio).toInt();
        }
      } else if (settings.mode == 'resolution') {
        final hMap = {'1080p': 1080, '720p': 720, '480p': 480, '360p': 360};
        final targetHeightVal = hMap[settings.targetResolution] ?? 720;
        if (targetH > targetHeightVal) {
          final ratio = targetHeightVal / targetH;
          targetW = (targetW * ratio).toInt();
          targetH = targetHeightVal;
        }
        if (targetHeightVal <= 480) targetBitrate = 800000;
        else if (targetHeightVal <= 720) targetBitrate = 2000000;
        else targetBitrate = 4000000;
      } else if (settings.mode == 'custom') {
        targetBitrate = (settings.bitrate * 1000000).toInt();
        targetFPS = settings.fps;
      }

      targetW = targetW.floor();
      targetH = targetH.floor();
      if (targetW % 2 != 0) targetW--;
      if (targetH % 2 != 0) targetH--;

      final canvas = html.CanvasElement(width: targetW, height: targetH);
      final ctx = canvas.context2D;
      final stream = canvas.captureStream(targetFPS);

      final supportedMimeType = ['video/webm;codecs=vp9', 'video/webm;codecs=vp8', 'video/mp4']
          .firstWhere((type) => html.MediaRecorder.isTypeSupported(type), orElse: () => 'video/webm');

      final mediaRecorder = html.MediaRecorder(stream, {
        'mimeType': supportedMimeType,
        'videoBitsPerSecond': targetBitrate,
      });

      final chunks = <html.Blob>[];
      final completer = Completer<Uint8List>();

      mediaRecorder.on['dataavailable'].listen((html.Event event) {
        // Use dynamic to avoid BlobEvent vs MessageEvent confusion in dart:html
        final dynamic blobEvent = event;
        if (blobEvent.data != null && (blobEvent.data as html.Blob).size > 0) {
          chunks.add(blobEvent.data as html.Blob);
        }
      });

      mediaRecorder.on['stop'].listen((_) async {
        final resultBlob = html.Blob(chunks, supportedMimeType);
        final reader = html.FileReader();
        reader.readAsArrayBuffer(resultBlob);
        await reader.onLoadEnd.first;
        completer.complete(reader.result as Uint8List);
      });

      mediaRecorder.start();
      await video.play();

      void draw(num _) {
        if (video.paused || video.ended) return;
        ctx.drawImageScaled(video, 0, 0, targetW, targetH);
        
        if (video.duration != null && video.duration! > 0) {
          final percent = ((video.currentTime / video.duration!) * 100).round();
          if (onProgress != null) onProgress(percent);
        }
        
        if (!video.ended) {
          html.window.requestAnimationFrame(draw);
        }
      }

      html.window.requestAnimationFrame(draw);

      video.onEnded.listen((_) {
        mediaRecorder.stop();
      });

      final resultBytes = await completer.future;
      html.Url.revokeObjectUrl(url);

      return file.copyWith(
        status: FileStatus.done,
        progress: 100,
        resultSize: resultBytes.length,
        bytes: resultBytes,
      );
    } catch (e) {
      print('Web video compression error: $e');
      return file.copyWith(status: FileStatus.error);
    }
  }

  Future<FileModel> compressImage(FileModel file, PhotoSettings settings) async {
    if (file.bytes == null) {
      return file.copyWith(status: FileStatus.error);
    }

    try {
      final blob = html.Blob([file.bytes!]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final img = html.ImageElement()..src = url;

      await img.onLoad.first;

      final w = (img.width! * settings.resize).toInt();
      final h = (img.height! * settings.resize).toInt();

      final canvas = html.CanvasElement(width: w, height: h);
      final ctx = canvas.context2D;
      ctx.drawImageScaled(img, 0, 0, w, h);

      final dataUrl = canvas.toDataUrl(settings.format, settings.quality);
      final String base64Data = dataUrl.split(',').last;
      final Uint8List resultBytes = base64.decode(base64Data);

      html.Url.revokeObjectUrl(url);

      return file.copyWith(
        status: FileStatus.done,
        progress: 100,
        resultSize: resultBytes.length,
        bytes: resultBytes,
      );
    } catch (e) {
      print('Web image compression error: $e');
      return file.copyWith(status: FileStatus.error);
    }
  }
}

