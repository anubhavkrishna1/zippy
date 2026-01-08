import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/archive.dart';
import '../models/file_item.dart';

class StorageService {
  static final StorageService instance = StorageService._();
  StorageService._();

  late Directory _appDirectory;
  late SharedPreferences _prefs;
  
  static const String _archivesKey = 'archives';
  
  Future<void> initialize() async {
    // Use platform-appropriate storage directory for archives
    // Android: External storage (app-specific, visible but still deleted on uninstall)
    // Linux: Documents directory in user's home (persists)
    // Other platforms: Application documents directory
    Directory baseDirectory;
    
    if (Platform.isAndroid) {
      // For Android, use external storage directory
      // Path: /storage/emulated/0/Android/data/[package]/files/zippy
      // Note: This is visible in file managers but still deleted on app uninstall
      // For true persistence, would need MediaStore API with MANAGE_EXTERNAL_STORAGE permission
      try {
        baseDirectory = await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
      } catch (e) {
        // Fall back to application documents directory
        baseDirectory = await getApplicationDocumentsDirectory();
      }
    } else if (Platform.isLinux) {
      // For Linux, use Documents directory in user's home
      // Path: ~/Documents/zippy
      // This persists after app uninstall
      try {
        final home = Platform.environment['HOME'];
        if (home != null) {
          baseDirectory = Directory('$home/Documents');
        } else {
          baseDirectory = await getApplicationDocumentsDirectory();
        }
      } catch (e) {
        baseDirectory = await getApplicationDocumentsDirectory();
      }
    } else {
      // For macOS, Windows, and other platforms, use application documents directory
      // On macOS, this typically points to ~/Library/Containers/app/Data/Documents
      baseDirectory = await getApplicationDocumentsDirectory();
    }
    
    // Create a 'zippy' subdirectory for storing archives
    _appDirectory = Directory('${baseDirectory.path}/zippy');
    
    // Create the directory if it doesn't exist
    if (!await _appDirectory.exists()) {
      await _appDirectory.create(recursive: true);
    }
    
    _prefs = await SharedPreferences.getInstance();
  }
  
  Directory get appDirectory => _appDirectory;
  
  Future<List<Archive>> getArchives() async {
    final String? archivesJson = _prefs.getString(_archivesKey);
    if (archivesJson == null) {
      return [];
    }
    
    final List<dynamic> archivesList = json.decode(archivesJson);
    return archivesList.map((e) => Archive.fromJson(e as Map<String, dynamic>)).toList();
  }
  
  Future<void> saveArchives(List<Archive> archives) async {
    final String archivesJson = json.encode(archives.map((e) => e.toJson()).toList());
    await _prefs.setString(_archivesKey, archivesJson);
  }
  
  Future<void> addArchive(Archive archive) async {
    final archives = await getArchives();
    archives.add(archive);
    await saveArchives(archives);
  }
  
  Future<void> updateArchive(Archive archive) async {
    final archives = await getArchives();
    final index = archives.indexWhere((a) => a.id == archive.id);
    if (index != -1) {
      archives[index] = archive;
      await saveArchives(archives);
    }
  }
  
  Future<void> deleteArchive(String archiveId) async {
    final archives = await getArchives();
    archives.removeWhere((a) => a.id == archiveId);
    await saveArchives(archives);
    
    // Delete the actual zip file
    final archiveFile = File('${_appDirectory.path}/$archiveId.zip');
    if (await archiveFile.exists()) {
      await archiveFile.delete();
    }
  }
  
  String getArchivePath(String archiveId) {
    return '${_appDirectory.path}/$archiveId.zip';
  }
  
  Future<List<FileItem>> getArchiveFiles(String archiveId) async {
    final filesJson = _prefs.getString('archive_files_$archiveId');
    if (filesJson == null) {
      return [];
    }
    
    final List<dynamic> filesList = json.decode(filesJson);
    return filesList.map((e) => FileItem.fromJson(e as Map<String, dynamic>)).toList();
  }
  
  Future<void> saveArchiveFiles(String archiveId, List<FileItem> files) async {
    final filesJson = json.encode(files.map((e) => e.toJson()).toList());
    await _prefs.setString('archive_files_$archiveId', filesJson);
  }
}
