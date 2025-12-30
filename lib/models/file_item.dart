import '../utils/format_utils.dart';

class FileItem {
  final String name;
  final int size;
  final DateTime addedAt;
  final String path;

  FileItem({
    required this.name,
    required this.size,
    required this.addedAt,
    required this.path,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'size': size,
      'addedAt': addedAt.toIso8601String(),
      'path': path,
    };
  }

  factory FileItem.fromJson(Map<String, dynamic> json) {
    return FileItem(
      name: json['name'] as String,
      size: json['size'] as int,
      addedAt: DateTime.parse(json['addedAt'] as String),
      path: json['path'] as String,
    );
  }

  String get formattedSize {
    return FormatUtils.formatSize(size);
  }
}
