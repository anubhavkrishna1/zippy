import 'package:flutter/material.dart';
import '../models/archive.dart';
import '../services/storage_service.dart';
import '../widgets/archive_card.dart';
import 'archive_detail_screen.dart';
import 'create_archive_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Archive> _archives = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadArchives();
  }

  Future<void> _loadArchives() async {
    setState(() => _isLoading = true);
    final archives = await StorageService.instance.getArchives();
    setState(() {
      _archives = archives;
      _isLoading = false;
    });
  }

  void _createNewArchive() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateArchiveScreen()),
    );
    
    if (result == true) {
      _loadArchives();
    }
  }

  void _openArchive(Archive archive) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ArchiveDetailScreen(archive: archive),
      ),
    );
    
    if (result == true) {
      _loadArchives();
    }
  }

  void _deleteArchive(Archive archive) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Archive'),
        content: Text('Are you sure you want to delete "${archive.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await StorageService.instance.deleteArchive(archive.id);
      _loadArchives();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zippy - Secure File Locker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showAboutDialog(
                context: context,
                applicationName: 'Zippy',
                applicationVersion: '1.0.0',
                applicationIcon: const Icon(Icons.lock, size: 48),
                children: [
                  const Text('A secure file archive manager with password protection.'),
                ],
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _archives.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.folder_off,
                        size: 100,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No archives yet',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap + to create your first secure archive',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadArchives,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: _archives.length,
                    itemBuilder: (context, index) {
                      final archive = _archives[index];
                      return ArchiveCard(
                        archive: archive,
                        onTap: () => _openArchive(archive),
                        onDelete: () => _deleteArchive(archive),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewArchive,
        tooltip: 'Create New Archive',
        child: const Icon(Icons.add),
      ),
    );
  }
}
