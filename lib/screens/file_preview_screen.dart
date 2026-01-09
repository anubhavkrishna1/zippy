import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../models/file_item.dart';
import '../services/archive_service.dart';

class FilePreviewScreen extends StatefulWidget {
  final FileItem file;
  final String archiveId;
  final String password;

  const FilePreviewScreen({
    super.key,
    required this.file,
    required this.archiveId,
    required this.password,
  });

  @override
  State<FilePreviewScreen> createState() => _FilePreviewScreenState();
}

class _FilePreviewScreenState extends State<FilePreviewScreen> {
  bool _isLoading = true;
  Uint8List? _fileBytes;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFile();
  }

  Future<void> _loadFile() async {
    setState(() => _isLoading = true);
    
    try {
      final bytes = await ArchiveService.instance.extractFile(
        widget.archiveId,
        widget.password,
        widget.file.name,
      );
      
      if (bytes != null) {
        setState(() {
          _fileBytes = bytes;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load file';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading file: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _exportFile() async {
    if (_fileBytes == null) return;

    try {
      // Get downloads directory (or temp directory as fallback)
      Directory? directory;
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
      } else {
        directory = await getApplicationDocumentsDirectory();
      }
      
      if (directory == null) {
        throw Exception('Could not access storage directory');
      }

      // Create a Downloads subdirectory
      final downloadsDir = Directory('${directory.path}/Downloads');
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }

      final filePath = '${downloadsDir.path}/${widget.file.name}';
      final file = File(filePath);
      await file.writeAsBytes(_fileBytes!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File exported to: ${downloadsDir.path}'),
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'OK',
              onPressed: () {},
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error exporting file: $e')),
        );
      }
    }
  }

  String _getFileExtension() {
    final parts = widget.file.name.split('.');
    if (parts.length > 1) {
      return parts.last.toLowerCase();
    }
    return '';
  }

  bool _isImageFile() {
    final ext = _getFileExtension();
    return ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(ext);
  }

  bool _isTextFile() {
    final ext = _getFileExtension();
    return ['txt', 'md', 'json', 'xml', 'html', 'css', 'js', 'dart', 'yaml', 'yml'].contains(ext);
  }

  Widget _buildPreviewContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadFile,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_fileBytes == null) {
      return const Center(child: Text('No data'));
    }

    // Image preview
    if (_isImageFile()) {
      return InteractiveViewer(
        minScale: 0.5,
        maxScale: 4.0,
        child: Center(
          child: Image.memory(
            _fileBytes!,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.broken_image, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('Unable to display image'),
                  ],
                ),
              );
            },
          ),
        ),
      );
    }

    // Text preview
    if (_isTextFile()) {
      try {
        final text = String.fromCharCodes(_fileBytes!);
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: SelectableText(
            text,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
          ),
        );
      } catch (e) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.description, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('Unable to display text file'),
              const SizedBox(height: 8),
              Text('Error: $e', style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        );
      }
    }

    // Unsupported file type
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.insert_drive_file, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text('Preview not available for this file type'),
          const SizedBox(height: 8),
          Text(
            'File type: ${_getFileExtension().toUpperCase()}',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _exportFile,
            icon: const Icon(Icons.download),
            label: const Text('Export to view externally'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.file.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _fileBytes != null ? _exportFile : null,
            tooltip: 'Export file',
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('File Info'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Name: ${widget.file.name}'),
                      const SizedBox(height: 8),
                      Text('Size: ${widget.file.formattedSize}'),
                      const SizedBox(height: 8),
                      Text('Type: ${_getFileExtension().toUpperCase()}'),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: _buildPreviewContent(),
    );
  }
}
