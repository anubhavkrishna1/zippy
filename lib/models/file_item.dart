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
    if (size < 1024) {
      return '$size B';
    } else if (size < 1024 * 1024) {
      return '${(size / 1024).toStringAsFixed(2)} KB';
    } else if (size < 1024 * 1024 * 1024) {
      return '${(size / (1024 * 1024)).toStringAsFixed(2)} MB';
    } else {
      return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    }
  }
}
