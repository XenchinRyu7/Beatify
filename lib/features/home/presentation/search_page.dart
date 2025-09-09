import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
      body: ListView.separated(
        itemCount: filtered.length,
        separatorBuilder: (_, __) => const Divider(height: 1, color: Colors.white12),
        itemBuilder: (context, index) {
          final s = filtered[index];
          return ListTile(
            leading: const Icon(Icons.music_note),
            title: Text(s.title, maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Text(s.artist, maxLines: 1, overflow: TextOverflow.ellipsis),
            onTap: () {
              ref.read(playerControllerProvider.notifier).setPlaylist(filtered, startIndex: index);
              Navigator.of(context).pushReplacement(
                PageRouteBuilder(pageBuilder: (_, __, ___) => const PlayerPage(), transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c)),
              );
            },
          );
        },
      ),
    );
  }
}


