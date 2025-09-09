import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../application/library_controller.dart';
import '../../player/application/player_controller.dart';
import '../../player/presentation/player_page.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final library = ref.watch(libraryControllerProvider);
    final filtered = _q.isEmpty
        ? library
        : library.where((s) => s.title.toLowerCase().contains(_q.toLowerCase()) || s.artist.toLowerCase().contains(_q.toLowerCase())).toList();

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Cari lagu atau artis', border: InputBorder.none),
          onChanged: (v) => setState(() => _q = v),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.clear), onPressed: () => setState(() => _q = '')),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          final s = filtered[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Theme.of(context).colorScheme.surface.withOpacity(0.10),
              border: Border.all(color: Colors.white.withOpacity(0.10)),
            ),
            child: ListTile(
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.16),
                ),
                child: Icon(
                  PhosphorIconsLight.musicNote,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              title: Text(
                s.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              subtitle: Text(
                s.artist,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70),
              ),
              onTap: () {
                ref.read(playerControllerProvider.notifier).setPlaylist(filtered, startIndex: index);
                Navigator.of(context).pushReplacement(
                  PageRouteBuilder(pageBuilder: (_, __, ___) => const PlayerPage(), transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c)),
                );
              },
            ),
          );
        },
      ),
    );
  }
}


