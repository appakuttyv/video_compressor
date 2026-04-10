import 'package:flutter/foundation.dart';
import 'package:disk_space/disk_space.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/processed_file.dart';

class StorageService {
  static const String _boxName = 'processed_files';

  Future<Map<String, int>> getStorageInfo() async {
    if (kIsWeb) {
      return {
        'total': 64 * 1024 * 1024 * 1024,
        'used': 45 * 1024 * 1024 * 1024,
        'free': 19 * 1024 * 1024 * 1024,
      };
    }

    try {
      final diskSpace = await DiskSpace.getFreeDiskSpace ?? 0;
      final totalSpace = await DiskSpace.getTotalDiskSpace ?? 0;
      final usedSpace = totalSpace - diskSpace;

      return {
        'total': (totalSpace * 1024 * 1024).toInt(),
        'used': (usedSpace * 1024 * 1024).toInt(),
        'free': (diskSpace * 1024 * 1024).toInt(),
      };
    } catch (e) {
      print('Error getting storage: $e');
      return {
        'total': 64 * 1024 * 1024 * 1024,
        'used': 0,
        'free': 64 * 1024 * 1024 * 1024,
      };
    }
  }

  Future<Map<String, int>> getMediaStorageBreakdown() async {
    final box = await Hive.openBox(_boxName);
    
    int videoSize = 0;
    int photoSize = 0;
    int docSize = 0; // Added

    for (var item in box.values) {
      final file = ProcessedFile.fromJson(Map<String, dynamic>.from(item));
      if (file.type == 'video') {
        videoSize += file.resultSize;
      } else if (file.type == 'image') {
        photoSize += file.resultSize;
      } else {
        docSize += file.resultSize;
      }
    }

    return {
      'videos': videoSize,
      'photos': photoSize,
      'docs': docSize, // Added
    };
  }
  
  Future<void> deleteProcessedFile(String id) async {
    final box = await Hive.openBox(_boxName);
    await box.delete(id);
  }

  Future<List<ProcessedFile>> getRecentFiles({int limit = 10}) async {
    final box = await Hive.openBox(_boxName);
    final files = box.values
        .map((item) => ProcessedFile.fromJson(Map<String, dynamic>.from(item)))
        .toList();
    files.sort((a, b) => b.processedDate.compareTo(a.processedDate));
    return files.take(limit).toList();
  }

  Future<void> saveProcessedFile(ProcessedFile file) async {
    final box = await Hive.openBox(_boxName);
    await box.put(file.id, file.toJson());
  }

  Future<void> clearHistory() async {
    final box = await Hive.openBox(_boxName);
    await box.clear();
  }
}
