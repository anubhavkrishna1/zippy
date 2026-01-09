import 'dart:io';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../models/file_item.dart';
import 'storage_service.dart';

class ArchiveService {
  static final ArchiveService instance = ArchiveService._();
  ArchiveService._();

  // NOTE: This implementation uses simple XOR-based encryption for demonstration purposes.
  // For production use, implement proper encryption using AES-256-GCM with secure key
  // derivation functions like PBKDF2 or Argon2. Consider using packages like:
  // - encrypt (for AES encryption)
  // - cryptography (for modern cryptographic algorithms)
  
  // Simple XOR-based encryption for demonstration
  Uint8List _encryptData(Uint8List data, String password) {
    final key = sha256.convert(utf8.encode(password)).bytes;
    final encrypted = Uint8List(data.length);
    
    for (int i = 0; i < data.length; i++) {
      encrypted[i] = data[i] ^ key[i % key.length];
    }
    
    return encrypted;
  }

  Uint8List _decryptData(Uint8List data, String password) {
    // XOR encryption is symmetric
    return _encryptData(data, password);
  }

  Future<void> createArchive(String archiveId, String password) async {
    final archive = Archive();
    final zipPath = StorageService.instance.getArchivePath(archiveId);
    
    final zipData = ZipEncoder().encode(archive);
    if (zipData != null) {
      final encrypted = _encryptData(Uint8List.fromList(zipData), password);
      await File(zipPath).writeAsBytes(encrypted);
    }
    
    await StorageService.instance.saveArchiveFiles(archiveId, []);
  }

  Future<List<FileItem>> getArchiveContents(String archiveId, String password) async {
    try {
      final zipPath = StorageService.instance.getArchivePath(archiveId);
      final zipFile = File(zipPath);
      
      if (!await zipFile.exists()) {
        return [];
      }
      
      final encrypted = await zipFile.readAsBytes();
      final decrypted = _decryptData(encrypted, password);
      
      try {
        final archive = ZipDecoder().decodeBytes(decrypted);
        final files = <FileItem>[];
        
        for (final file in archive) {
          if (file.isFile) {
            files.add(FileItem(
              name: file.name,
              size: file.size,
              addedAt: DateTime.now(),
              path: file.name,
            ));
          }
        }
        
        return files;
      } catch (e) {
        // If decryption fails, password is wrong
        throw Exception('Invalid password');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addFilesToArchive(
    String archiveId,
    String password,
    List<File> filesToAdd,
  ) async {
    final zipPath = StorageService.instance.getArchivePath(archiveId);
    final zipFile = File(zipPath);
    
    Archive existingArchive;
    
    if (await zipFile.exists()) {
      final encrypted = await zipFile.readAsBytes();
      final decrypted = _decryptData(encrypted, password);
      
      try {
        existingArchive = ZipDecoder().decodeBytes(decrypted);
      } catch (e) {
        throw Exception('Invalid password');
      }
    } else {
      existingArchive = Archive();
    }
    
    // Create a new mutable archive
    final newArchive = Archive();
    
    // Get list of filenames to add
    final fileNamesToAdd = filesToAdd.map((f) => f.path.split('/').last).toSet();
    
    // Copy existing files except ones being replaced
    for (final existingFile in existingArchive.files) {
      if (!fileNamesToAdd.contains(existingFile.name)) {
        newArchive.addFile(existingFile);
      }
    }
    
    // Add new files to the archive
    for (final file in filesToAdd) {
      final fileName = file.path.split('/').last;
      final fileBytes = await file.readAsBytes();
      
      // Add new file
      newArchive.addFile(ArchiveFile(
        fileName,
        fileBytes.length,
        fileBytes,
      ));
    }
    
    // Encode and encrypt
    final zipData = ZipEncoder().encode(newArchive);
    if (zipData != null) {
      final encrypted = _encryptData(Uint8List.fromList(zipData), password);
      await zipFile.writeAsBytes(encrypted);
    }
    
    // Update file list in storage
    final fileItems = <FileItem>[];
    for (final file in newArchive.files) {
      if (file.isFile) {
        fileItems.add(FileItem(
          name: file.name,
          size: file.size,
          addedAt: DateTime.now(),
          path: file.name,
        ));
      }
    }
    await StorageService.instance.saveArchiveFiles(archiveId, fileItems);
  }

  Future<void> removeFileFromArchive(
    String archiveId,
    String password,
    String fileName,
  ) async {
    final zipPath = StorageService.instance.getArchivePath(archiveId);
    final zipFile = File(zipPath);
    
    if (!await zipFile.exists()) {
      return;
    }
    
    final encrypted = await zipFile.readAsBytes();
    final decrypted = _decryptData(encrypted, password);
    
    Archive existingArchive;
    try {
      existingArchive = ZipDecoder().decodeBytes(decrypted);
    } catch (e) {
      throw Exception('Invalid password');
    }
    
    // Create a new mutable archive
    final newArchive = Archive();
    
    // Copy all files except the one to remove
    for (final existingFile in existingArchive.files) {
      if (existingFile.name != fileName) {
        newArchive.addFile(existingFile);
      }
    }
    
    // Encode and encrypt
    final zipData = ZipEncoder().encode(newArchive);
    if (zipData != null) {
      final encrypted = _encryptData(Uint8List.fromList(zipData), password);
      await zipFile.writeAsBytes(encrypted);
    }
    
    // Update file list in storage
    final fileItems = <FileItem>[];
    for (final file in newArchive.files) {
      if (file.isFile) {
        fileItems.add(FileItem(
          name: file.name,
          size: file.size,
          addedAt: DateTime.now(),
          path: file.name,
        ));
      }
    }
    await StorageService.instance.saveArchiveFiles(archiveId, fileItems);
  }

  Future<bool> verifyPassword(String archiveId, String password) async {
    try {
      await getArchiveContents(archiveId, password);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Extract a single file from archive and return its bytes
  Future<Uint8List?> extractFile(
    String archiveId,
    String password,
    String fileName,
  ) async {
    final zipPath = StorageService.instance.getArchivePath(archiveId);
    final zipFile = File(zipPath);
    
    if (!await zipFile.exists()) {
      throw Exception('Archive file not found');
    }
    
    final encrypted = await zipFile.readAsBytes();
    final decrypted = _decryptData(encrypted, password);
    
    try {
      final archive = ZipDecoder().decodeBytes(decrypted);
      
      for (final file in archive) {
        if (file.isFile && file.name == fileName) {
          return Uint8List.fromList(file.content as List<int>);
        }
      }
      
      return null; // File not found in archive
    } catch (e) {
      throw Exception('Failed to decrypt archive or file not found: $e');
    }
  }

  // Extract file to external storage
  Future<String?> exportFile(
    String archiveId,
    String password,
    String fileName,
    String destinationPath,
  ) async {
    final fileBytes = await extractFile(archiveId, password, fileName);
    if (fileBytes == null) {
      return null;
    }
    
    final outputFile = File(destinationPath);
    await outputFile.writeAsBytes(fileBytes);
    return destinationPath;
  }

  // Extract all files from archive to a directory
  Future<List<String>> extractAllFiles(
    String archiveId,
    String password,
    String destinationDir,
  ) async {
    final zipPath = StorageService.instance.getArchivePath(archiveId);
    final zipFile = File(zipPath);
    
    if (!await zipFile.exists()) {
      throw Exception('Archive file not found');
    }
    
    final encrypted = await zipFile.readAsBytes();
    final decrypted = _decryptData(encrypted, password);
    
    final Archive archive;
    try {
      archive = ZipDecoder().decodeBytes(decrypted);
    } catch (e) {
      throw Exception('Failed to decrypt archive: $e');
    }
    
    final extractedFiles = <String>[];
    
    for (final file in archive) {
      if (file.isFile) {
        // Sanitize filename to prevent path traversal
        // Use only the base filename, not any path components
        final sanitizedName = file.name.split('/').last.split('\\').last;
        if (sanitizedName.isEmpty) continue;
        
        // Remove dangerous characters
        final safeName = sanitizedName.replaceAll(RegExp(r'[<>:"|?*]'), '_');
        
        final filePath = '$destinationDir/$safeName';
        final outputFile = File(filePath);
        
        // Create parent directory if needed
        await outputFile.parent.create(recursive: true);
        
        await outputFile.writeAsBytes(file.content as List<int>);
        extractedFiles.add(filePath);
      }
    }
    
    return extractedFiles;
  }
}
