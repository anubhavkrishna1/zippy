class Archive {
  final String id;
  final String name;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final int fileCount;
  final int totalSize;

  Archive({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.modifiedAt,
    required this.fileCount,
    required this.totalSize,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
      'modifiedAt': modifiedAt.toIso8601String(),
      'fileCount': fileCount,
      'totalSize': totalSize,
    };
  }

  factory Archive.fromJson(Map<String, dynamic> json) {
    return Archive(
      id: json['id'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      modifiedAt: DateTime.parse(json['modifiedAt'] as String),
      fileCount: json['fileCount'] as int,
      totalSize: json['totalSize'] as int,
    );
  }

  Archive copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    DateTime? modifiedAt,
    int? fileCount,
    int? totalSize,
  }) {
    return Archive(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      fileCount: fileCount ?? this.fileCount,
      totalSize: totalSize ?? this.totalSize,
    );
  }
}
