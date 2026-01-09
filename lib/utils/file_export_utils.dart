import 'dart:io';
import 'package:path_provider/path_provider.dart';

class FileExportUtils {
  /// Get the Downloads directory for exporting files
  /// Returns the Downloads directory on Android, documents directory on other platforms
  static Future<Directory> getExportDirectory() async {
    Directory? directory;
    if (Platform.isAndroid) {
      // Try to get the Downloads directory
      // path_provider's getDownloadsDirectory() may not be available on all versions
      try {
        directory = await getDownloadsDirectory();
      } catch (e) {
        // Fall back to external storage directory if Downloads not available
        directory = await getExternalStorageDirectory();
      }
      
      // If we got the app-specific external storage, use public Downloads instead
      // On Android, we want /storage/emulated/0/Download (the public Downloads folder)
      if (directory != null && directory.path.contains('/Android/data/')) {
        // Use the public Downloads directory
        // Path: /storage/emulated/0/Download
        final parts = directory.path.split('/Android/data/');
        if (parts.isNotEmpty) {
          final basePath = parts[0]; // Gets /storage/emulated/0
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
