import 'dart:io';
import 'package:path_provider/path_provider.dart';

class FileExportUtils {
  /// Get the Downloads directory for exporting files
  /// Returns the Downloads directory on Android, documents directory on other platforms
  static Future<Directory> getExportDirectory() async {
    Directory? directory;
    if (Platform.isAndroid) {
      // Get the external storage directory (app-specific on Android 10+)
      directory = await getExternalStorageDirectory();
      
      // If we got the app-specific external storage, construct path to public Downloads
      // On Android, we want /storage/emulated/0/Download (the public Downloads folder)
      // App-specific path format: /storage/emulated/0/Android/data/{package}/files
      if (directory != null) {
        final path = directory.path;
        final androidDataIndex = path.indexOf('/Android/data/');
        if (androidDataIndex != -1) {
          // Extract the base path (e.g., /storage/emulated/0)
          final basePath = path.substring(0, androidDataIndex);
          // Construct public Downloads directory path
          directory = Directory('$basePath/Download');
        }
      }
    } else {
      directory = await getApplicationDocumentsDirectory();
    }
    
    if (directory == null) {
      throw Exception('Could not access storage directory');
    }

    // For non-Android platforms, create a Downloads subdirectory
    if (!Platform.isAndroid) {
      directory = Directory('${directory.path}/Downloads');
    }
    
    // Ensure the directory exists
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    return directory;
  }

  /// Sanitize a filename to prevent path traversal attacks
  /// Removes or replaces path separators and other potentially dangerous characters
  static String sanitizeFileName(String fileName) {
    // Remove path separators and parent directory references
    String sanitized = fileName.replaceAll(RegExp(r'[\\/]+'), '_');
    sanitized = sanitized.replaceAll('..', '_');
    
    // Remove or replace other potentially dangerous characters
    sanitized = sanitized.replaceAll(RegExp(r'[<>:"|?*]'), '_');
    
    // Ensure the filename is not empty
    if (sanitized.trim().isEmpty) {
      sanitized = 'file';
    }
    
    return sanitized;
  }

  /// Generate a unique file path to avoid overwriting existing files
  /// If the file exists, appends (1), (2), etc. to the filename
  static Future<String> getUniqueFilePath(String directory, String fileName) async {
    final sanitizedName = sanitizeFileName(fileName);
    String candidatePath = '$directory/$sanitizedName';
    File file = File(candidatePath);

    if (!await file.exists()) {
      return candidatePath;
    }

    // Split the filename into base name and extension
    final dotIndex = sanitizedName.lastIndexOf('.');
    String baseName;
    String extension;

    if (dotIndex != -1) {
      baseName = sanitizedName.substring(0, dotIndex);
      extension = sanitizedName.substring(dotIndex); // includes the dot
    } else {
      baseName = sanitizedName;
      extension = '';
    }

    int counter = 1;
    // Increment suffix until an available filename is found
    while (await file.exists()) {
      final newName = '$baseName ($counter)$extension';
      candidatePath = '$directory/$newName';
      file = File(candidatePath);
      counter++;
    }

    return candidatePath;
  }

  /// Check if files will be overwritten and get their count
  static Future<int> countExistingFiles(String directory, List<String> fileNames) async {
    int count = 0;
    for (final fileName in fileNames) {
      final sanitizedName = sanitizeFileName(fileName);
      final filePath = '$directory/$sanitizedName';
      if (await File(filePath).exists()) {
        count++;
      }
    }
    return count;
  }
}
