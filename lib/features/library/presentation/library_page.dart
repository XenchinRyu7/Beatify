import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/song.dart';
import '../../../domain/repositories/song_repository.dart';
import '../../../features/player/application/player_controller.dart';
import '../../../services/overrides_service.dart';
import '../../../services/permission_service.dart';

class LibraryPage extends ConsumerStatefulWidget {
  const LibraryPage({super.key});

  @override
  ConsumerState<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends ConsumerState<LibraryPage> {
  final _permission = PermissionService();
  List<Song> _songs = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final ok = await _permission.ensureAudioPermission();
    if (ok) {
      final repo = ref.read(songRepositoryProvider);
      _songs = await repo.getAllSongs();
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
      onRefresh: () async {
        setState(() => _loading = true);
        await _init();
      },
      child: _loading
          ? ListView(children: const [SizedBox(height: 300), Center(child: CircularProgressIndicator())])
          : (_songs.isEmpty
              ? ListView(children: const [SizedBox(height: 300), Center(child: Text('Tidak ada lagu ditemukan'))])
              : ListView.separated(
                  padding: const EdgeInsets.only(bottom: 90),
                  itemCount: _songs.length,
                  separatorBuilder: (_, __) => const Divider(height: 1, color: Colors.white12),
                  itemBuilder: (context, index) {
                    final s = _songs[index];
                    return ListTile(
                      leading: const Icon(Icons.music_note),
                      title: Text(s.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                      subtitle: Text(s.artist, maxLines: 1, overflow: TextOverflow.ellipsis),
                      onTap: () async {
                        final controller = ref.read(playerControllerProvider.notifier);
                        controller.load().then((_) => controller.playAt(index));
                      },
                      trailing: PopupMenuButton<String>(
                        onSelected: (v) async {
                          if (v == 'rename') {
                            final newName = await _promptText(context, 'Rename', s.title);
                            if (newName != null && newName.trim().isNotEmpty) {
                              // Rename file on disk
                              await _renameFile(s, newName.trim());
                              await _init();
                            }
                          } else if (v == 'artist') {
                            final newArtist = await _promptText(context, 'Edit Artist', s.artist);
                            if (newArtist != null) {
                              final trimmed = newArtist.trim();
                              await _saveArtistOverride(s, trimmed);
                              // realtime update state playlist
                              ref.read(playerControllerProvider.notifier).updateArtist(s.id, trimmed);
                              // update local list for immediate UI feedback
                              setState(() {
                                _songs[index] = Song(
                                  id: s.id,
                                  title: s.title,
                                  artist: trimmed,
                                  coverUrl: s.coverUrl,
                                  url: s.url,
                                  audioId: s.audioId,
                                );
                              });
                            }
                          } else if (v == 'delete') {
                            await _deleteFile(s);
                            await _init();
                          }
                        },
                        itemBuilder: (ctx) => const [
                          PopupMenuItem(value: 'rename', child: Text('Rename')),
                          PopupMenuItem(value: 'artist', child: Text('Edit artist')),
                          PopupMenuItem(value: 'delete', child: Text('Delete')),
                        ],
                      ),
                    );
                  },
                )),
    ));
  }

  Future<String?> _promptText(BuildContext context, String title, String initial) async {
    final ctrl = TextEditingController(text: initial);
    return showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: TextField(controller: ctrl, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(context, ctrl.text), child: const Text('Simpan')),
        ],
      ),
    );
  }

  Future<void> _renameFile(Song s, String newBaseName) async {
    try {
      final path = Uri.parse(s.url).toFilePath();
      final file = File(path);
      final dir = file.parent;
      final newPath = '${dir.path}/$newBaseName${path.contains('.') ? path.substring(path.lastIndexOf('.')) : ''}';
      await file.rename(newPath);
    } catch (_) {}
  }

  Future<void> _deleteFile(Song s) async {
    try {
      final path = Uri.parse(s.url).toFilePath();
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}
  }

  Future<void> _saveArtistOverride(Song s, String newArtist) async {
    // store override via MetadataOverridesService
    final service = OverridesService.instance;
    await service.setArtistOverride(s.id, newArtist);
  }
}


