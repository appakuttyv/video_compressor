import 'dart:typed_data';

class ProcessedFile {
  String id;
  String name;
  String type; // 'video' or 'image' or 'pdf'
  int originalSize;
  int resultSize;
  DateTime processedDate;
  String? savedPath;
  Uint8List? bytes; // Not serialized
  String? status; // 'done', 'cancelled', 'failed'
  String? originalPath; // For retry

  ProcessedFile({
    required this.id,
    required this.name,
    required this.type,
    required this.originalSize,
    required this.resultSize,
    required this.processedDate,
    this.savedPath,
    this.bytes,
    this.status = 'done',
    this.originalPath,
  });

  int get savedBytes => originalSize - resultSize;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type,
    'originalSize': originalSize,
    'resultSize': resultSize,
    'processedDate': processedDate.toIso8601String(),
    'savedPath': savedPath,
    'status': status,
    'originalPath': originalPath,
  };

  factory ProcessedFile.fromJson(Map<String, dynamic> json) => ProcessedFile(
    id: json['id'],
    name: json['name'],
    type: json['type'],
    originalSize: json['originalSize'],
    resultSize: json['resultSize'],
    processedDate: DateTime.parse(json['processedDate']),
    savedPath: json['savedPath'],
    bytes: null,
    status: json['status'] ?? 'done',
    originalPath: json['originalPath'],
  );
}
