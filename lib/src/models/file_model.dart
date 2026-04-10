
import 'dart:io';
import 'dart:typed_data'; // For Uint8List

enum FileStatus { idle, processing, done, error, cancelled }
enum MediaType { video, image, pdf }

class FileModel {
  String id;
  File? file; // Nullable for web
  Uint8List? bytes; // For web
  String name;
  MediaType type;
  int originalSize;
  FileStatus status;
  int progress;
  File? resultFile;
  int resultSize;
  FileMeta meta;
  bool selected;

  FileModel({
    required this.id,
    this.file,
    this.bytes,
    required this.name,
    required this.type,
    this.originalSize = 0,
    this.status = FileStatus.idle,
    this.progress = 0,
    this.resultFile,
    this.resultSize = 0,
    this.meta = const FileMeta(),
    this.selected = true,
  });

  FileModel copyWith({
    String? id,
    File? file,
    Uint8List? bytes,
    String? name,
    MediaType? type,
    int? originalSize,
    FileStatus? status,
    int? progress,
    File? resultFile,
    int? resultSize,
    FileMeta? meta,
    bool? selected,
  }) {
    return FileModel(
      id: id ?? this.id,
      file: file ?? this.file,
      bytes: bytes ?? this.bytes,
      name: name ?? this.name,
      type: type ?? this.type,
      originalSize: originalSize ?? this.originalSize,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      resultFile: resultFile ?? this.resultFile,
      resultSize: resultSize ?? this.resultSize,
      meta: meta ?? this.meta,
      selected: selected ?? this.selected,
    );
  }
}

class FileMeta {
  final double duration; // seconds
  final int width;
  final int height;

  const FileMeta({this.duration = 0, this.width = 0, this.height = 0});
}
