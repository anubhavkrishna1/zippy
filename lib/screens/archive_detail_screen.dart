import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../models/archive.dart';
import '../models/file_item.dart';
import '../services/storage_service.dart';
import '../services/archive_service.dart';
import '../widgets/file_item_card.dart';
import '../utils/format_utils.dart';
import '../utils/file_export_utils.dart';
import 'file_preview_screen.dart';

class ArchiveDetailScreen extends StatefulWidget {
  final Archive archive;

  const ArchiveDetailScreen({
    super.key,
    required this.archive,
  });

  @override
  State<ArchiveDetailScreen> createState() => _ArchiveDetailScreenState();
}

class _ArchiveDetailScreenState extends State<ArchiveDetailScreen> {
  List<FileItem> _files = [];
  bool _isLoading = true;
  bool _isUnlocked = false;
  String _password = '';

  @override
  void initState() {
    super.initState();
    _showPasswordDialog();
  }

  Future<void> _showPasswordDialog() async {
    final passwordController = TextEditingController();
    bool obscurePassword = true;

    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Enter Password'),
          content: TextField(
            controller: passwordController,
            obscureText: obscurePassword,
            decoration: InputDecoration(
              labelText: 'Password',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(
                  obscurePassword ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setDialogState(() => obscurePassword = !obscurePassword);
                },
              ),
            ),
            autofocus: true,
            onSubmitted: (value) => Navigator.pop(context, value),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, passwordController.text),
              child: const Text('Unlock'),
            ),
          ],
        ),
      ),
    );

    if (result == null) {
      if (mounted) {
        Navigator.pop(context);
      }
      return;
    }

    final isValid = await ArchiveService.instance.verifyPassword(
      widget.archive.id,
      result,
    );

    if (isValid) {
      setState(() {
        _password = result;
        _isUnlocked = true;
      });
      _loadFiles();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid password')),
        );
        _showPasswordDialog();
      }
    }
  }

  Future<void> _loadFiles() async {
    setState(() => _isLoading = true);
    try {
      final files = await ArchiveService.instance.getArchiveContents(
        widget.archive.id,
        _password,
      );
      setState(() {
        _files = files;
        _isLoading = false;
      });

      // Update archive metadata
      final totalSize = _files.fold<int>(0, (sum, file) => sum + file.size);
      final updatedArchive = widget.archive.copyWith(
        fileCount: _files.length,
        totalSize: totalSize,
        modifiedAt: DateTime.now(),
      );
      await StorageService.instance.updateArchive(updatedArchive);
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading files: $e')),
        );
      }
    }
  }

  Future<void> _addFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.any,
    );

    if (result == null) return;

    setState(() => _isLoading = true);

    try {
      final files = result.paths
          .where((path) => path != null)
          .map((path) => File(path!))
          .toList();

      await ArchiveService.instance.addFilesToArchive(
        widget.archive.id,
        _password,
        files,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Added ${files.length} file(s)')),
        );
      }

      _loadFiles();
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding files: $e')),
        );
      }
    }
  }

  Future<void> _removeFile(FileItem file) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove File'),
        content: Text('Remove "${file.name}" from the archive?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      await ArchiveService.instance.removeFileFromArchive(
        widget.archive.id,
        _password,
        file.name,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File removed')),
        );
      }

      _loadFiles();
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error removing file: $e')),
        );
      }
    }
  }

  Future<void> _exportFile(FileItem file) async {
    try {
      setState(() => _isLoading = true);

      final downloadsDir = await FileExportUtils.getExportDirectory();
      
      // Get unique file path to avoid overwriting
      final filePath = await FileExportUtils.getUniqueFilePath(
        downloadsDir.path,
        file.name,
      );
      
      final result = await ArchiveService.instance.exportFile(
        widget.archive.id,
        _password,
        file.name,
        filePath,
      );

      setState(() => _isLoading = false);

      if (result != null && mounted) {
        final fileName = filePath.split('/').last;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File exported as: $fileName'),
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'OK',
              onPressed: () {},
            ),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to export file')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error exporting file: $e')),
        );
      }
    }
  }

  Future<void> _exportAllFiles() async {
    try {
      // First check if files will be overwritten
      final downloadsDir = await FileExportUtils.getExportDirectory();
      final archiveDir = Directory('${downloadsDir.path}/${widget.archive.name}');
      
      int existingCount = 0;
      if (await archiveDir.exists()) {
        final fileNames = _files.map((f) => f.name).toList();
        existingCount = await FileExportUtils.countExistingFiles(
          archiveDir.path,
          fileNames,
        );
      }

      String confirmMessage = 'Extract all ${_files.length} file(s) to Downloads folder?';
      if (existingCount > 0) {
        confirmMessage = 'Extract all ${_files.length} file(s)?\n\nWarning: $existingCount existing file(s) will be overwritten.';
      }

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Extract All Files'),
          content: Text(confirmMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Extract'),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      setState(() => _isLoading = true);

      // Create the archive subdirectory
      if (!await archiveDir.exists()) {
        await archiveDir.create(recursive: true);
      }

      final extractedFiles = await ArchiveService.instance.extractAllFiles(
        widget.archive.id,
        _password,
        archiveDir.path,
      );

      setState(() => _isLoading = false);

      if (extractedFiles.isNotEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Extracted ${extractedFiles.length} file(s) to: ${archiveDir.path}'),
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'OK',
              onPressed: () {},
            ),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No files were extracted')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error extracting files: $e')),
        );
      }
    }
  }

  void _openFilePreview(FileItem file) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FilePreviewScreen(
          file: file,
          archiveId: widget.archive.id,
          password: _password,
        ),
      ),
    );
  }

  String _formatTotalSize() {
    final totalSize = _files.fold<int>(0, (sum, file) => sum + file.size);
    return FormatUtils.formatSize(totalSize);
  }

  @override
  Widget build(BuildContext context) {
    if (!_isUnlocked) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.archive.name),
        actions: [
          if (_files.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: _exportAllFiles,
              tooltip: 'Extract all files',
            ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Archive Info'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Name: ${widget.archive.name}'),
                      const SizedBox(height: 8),
                      Text('Files: ${_files.length}'),
                      const SizedBox(height: 8),
                      Text('Total Size: ${_formatTotalSize()}'),
                      const SizedBox(height: 8),
                      Text('Created: ${_formatDate(widget.archive.createdAt)}'),
                      const SizedBox(height: 8),
                      Text('Modified: ${_formatDate(widget.archive.modifiedAt)}'),
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _files.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.file_present,
                        size: 100,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No files in this archive',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap + to add files',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: Colors.deepPurple[50],
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Text(
                                '${_files.length}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text('Files'),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                _formatTotalSize(),
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text('Total Size'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _files.length,
                        itemBuilder: (context, index) {
                          final file = _files[index];
                          return FileItemCard(
                            file: file,
                            onDelete: () => _removeFile(file),
                            onTap: () => _openFilePreview(file),
                            onExport: () => _exportFile(file),
                          );
                        },
                      ),
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addFiles,
        tooltip: 'Add Files',
        child: const Icon(Icons.add),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return FormatUtils.formatDate(date);
  }
}
