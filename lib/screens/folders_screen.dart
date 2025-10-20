import 'package:flutter/material.dart';
import '../data/folder_repository.dart';
import '../models/folder.dart';
import 'cards_screen.dart';

class FoldersScreen extends StatefulWidget {
  const FoldersScreen({super.key});
  @override
  State<FoldersScreen> createState() => _FoldersScreenState();
}

class _FoldersScreenState extends State<FoldersScreen> {
  final repo = FolderRepository();
  late Future<List<Folder>> folders;

  @override
  void initState() {
    super.initState();
    folders = repo.getAllFolders();
  }

  Future<void> _refresh() async {
    setState(() {
      folders = repo.getAllFolders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final warn = TextStyle(
      color: Theme.of(context).colorScheme.error,
      fontWeight: FontWeight.w600,
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Card Folders')),
      body: FutureBuilder<List<Folder>>(
        future: folders,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());
          if (snap.hasError) return Center(child: Text('Error: ${snap.error}'));
          final data = snap.data ?? [];
          return RefreshIndicator(
            onRefresh: _refresh,
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
              itemCount: data.length,
              itemBuilder: (context, i) {
                final f = data[i];
                return FutureBuilder<int>(
                  future: repo.countInFolder(f.id!),
                  builder: (context, cntSnap) {
                    final count = cntSnap.data ?? 0;
                    return InkWell(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CardsScreen(folder: f),
                        ),
                      ).then((_) => _refresh()),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (f.previewImage != null &&
                                  f.previewImage!.isNotEmpty)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    f.previewImage!,
                                    height: 80,
                                    width: 80,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        const Icon(Icons.broken_image),
                                  ),
                                )
                              else
                                const Icon(Icons.folder, size: 64),
                              const SizedBox(height: 8),
                              Text(
                                f.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text('$count cards'),
                              if (count < 3)
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Text('Need at least 3', style: warn),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
