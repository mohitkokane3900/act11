import 'package:flutter/material.dart';
import '../data/card_repository.dart';
import '../data/folder_repository.dart';
import '../models/card_item.dart';
import '../models/folder.dart';

class CardsScreen extends StatefulWidget {
  final Folder folder;
  const CardsScreen({super.key, required this.folder});
  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  final cardsRepo = CardRepository();
  final foldersRepo = FolderRepository();
  late Future<List<CardItem>> cards;

  @override
  void initState() {
    super.initState();
    cards = cardsRepo.getCardsByFolder(widget.folder.id!);
  }

  void _refresh() {
    setState(() {
      cards = cardsRepo.getCardsByFolder(widget.folder.id!);
    });
  }

  Future<void> _addCard() async {
    final suit = widget.folder.name;
    final suitLetter = {
      'Hearts': 'H',
      'Spades': 'S',
      'Diamonds': 'D',
      'Clubs': 'C',
    }[suit]!;
    final options =
        ['ACE', '2', '3', '4', '5', '6', '7', '8', '9', '0', 'J', 'Q', 'K'].map(
          (r) {
            final url =
                'https://deckofcardsapi.com/static/img/${r}${suitLetter}.png';
            final nm = r == '0'
                ? '10 of $suit'
                : (r == 'ACE' ? 'Ace of $suit' : '$r of $suit');
            return CardItem(
              name: nm,
              suit: suit,
              imageUrl: url,
              folderId: widget.folder.id!,
              createdAt: DateTime.now(),
            );
          },
        ).toList();

    final existing = await cardsRepo.getCardsByFolder(widget.folder.id!);
    final existNames = existing.map((e) => e.name).toSet();
    final available = options
        .where((c) => !existNames.contains(c.name))
        .toList();
    if (available.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No more cards available.')));
      return;
    }

    final selected = await showModalBottomSheet<CardItem>(
      context: context,
      builder: (_) => ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: available.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final c = available[i];
          return ListTile(
            leading: SizedBox(
              width: 44,
              height: 44,
              child: Image.network(
                c.imageUrl,
                errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
              ),
            ),
            title: Text(c.name),
            onTap: () => Navigator.pop(context, c),
          );
        },
      ),
    );
    if (selected == null) return;

    await cardsRepo.insertCard(selected);
    await foldersRepo.updatePreview(widget.folder.id!, selected.imageUrl);
    _refresh();
  }

  Future<void> _renameCard(CardItem c) async {
    final ctl = TextEditingController(text: c.name);
    final res = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Rename Card'),
        content: TextField(
          controller: ctl,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Card Name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, ctl.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (res == null || res.isEmpty) return;
    await cardsRepo.updateCard(
      CardItem(
        id: c.id,
        name: res,
        suit: c.suit,
        imageUrl: c.imageUrl,
        folderId: c.folderId,
        createdAt: c.createdAt,
      ),
    );
    _refresh();
  }

  Future<void> _deleteCard(CardItem c) async {
    await cardsRepo.deleteCard(c.id!);
    final remaining = await cardsRepo.getCardsByFolder(widget.folder.id!);
    if (remaining.isEmpty) {
      await foldersRepo.updatePreview(widget.folder.id!, '');
    } else {
      await foldersRepo.updatePreview(
        widget.folder.id!,
        remaining.first.imageUrl,
      );
    }
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.folder.name),
        actions: [IconButton(onPressed: _addCard, icon: const Icon(Icons.add))],
      ),
      body: FutureBuilder<List<CardItem>>(
        future: cards,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());
          if (snap.hasError) return Center(child: Text('Error: ${snap.error}'));
          final data = snap.data ?? [];
          if (data.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('No cards yet'),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    onPressed: _addCard,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Card'),
                  ),
                ],
              ),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 3 / 4,
            ),
            itemCount: data.length,
            itemBuilder: (context, i) {
              final c = data[i];
              return InkWell(
                onTap: () => _renameCard(c),
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      Expanded(
                        child: Image.network(
                          c.imageUrl,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.broken_image, size: 64),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                c.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              onPressed: () => _deleteCard(c),
                              icon: const Icon(Icons.delete, color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCard,
        child: const Icon(Icons.add),
      ),
    );
  }
}
