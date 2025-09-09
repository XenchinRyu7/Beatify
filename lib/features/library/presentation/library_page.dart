import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../domain/entities/song.dart';
import '../../../domain/repositories/song_repository.dart';
import '../../../features/player/application/player_controller.dart';
import '../../../services/overrides_service.dart';
import '../../../services/permission_service.dart';
import '../../home/application/library_controller.dart';

class LibraryPage extends ConsumerStatefulWidget {
  const LibraryPage({super.key});

  @override
  ConsumerState<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends ConsumerState<LibraryPage> {
  final _permission = PermissionService();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final ok = await _permission.ensureAudioPermission();
    if (ok) {
      await ref.read(libraryControllerProvider.notifier).load();
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final songs = ref.watch(libraryControllerProvider);
    
    return SafeArea(
      child: RefreshIndicator(
      onRefresh: () async {
        setState(() => _loading = true);
        await _init();
      },
      child: _loading
          ? ListView(children: const [SizedBox(height: 300), Center(child: CircularProgressIndicator())])
          : (songs.isEmpty
              ? ListView(children: const [SizedBox(height: 300), Center(child: Text('Tidak ada lagu ditemukan'))])
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
                  itemCount: songs.length,
                  itemBuilder: (context, index) {
                    final s = songs[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Theme.of(context).colorScheme.surface.withOpacity(0.06),
                        border: Border.all(color: Colors.white.withOpacity(0.06)),
                      ),
                      child: ListTile(
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
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
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(
                          s.artist,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                        onTap: () async {
                          final controller = ref.read(playerControllerProvider.notifier);
                          controller.load().then((_) => controller.playAt(index));
                        },
                        trailing: PopupMenuButton<String>(
                          onSelected: (v) async {
                            if (v == 'rename') {
                              final newName = await _promptText(context, 'Rename', s.title);
                            if (newName != null && newName.trim().isNotEmpty) {
                              await _renameFile(s, newName.trim());
                              await ref.read(libraryControllerProvider.notifier).load();
                            }
                            } else if (v == 'artist') {
                              final newArtist = await _promptText(context, 'Edit Artist', s.artist);
                              if (newArtist != null) {
                                final trimmed = newArtist.trim();
                                await _saveArtistOverride(s, trimmed);
                                ref.read(playerControllerProvider.notifier).updateArtist(s.id, trimmed);
                                await ref.read(libraryControllerProvider.notifier).load();
                              }
                            } else if (v == 'delete') {
                              await _deleteFile(s);
                              await ref.read(libraryControllerProvider.notifier).load();
                            }
                          },
                          itemBuilder: (ctx) => const [
                            PopupMenuItem(value: 'rename', child: Text('Rename')),
                            PopupMenuItem(value: 'artist', child: Text('Edit artist')),
                            PopupMenuItem(value: 'delete', child: Text('Delete')),
                          ],
                        ),
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
      // For MediaStore songs, we can't directly rename the file
      // Instead, we'll update the title in the overrides service
      // and reload the library to reflect the change
      
      // Save the new title as an override
      final service = OverridesService.instance;
      await service.setTitleOverride(s.id, newBaseName);
      
      // Update in player controller if it's currently playing
      ref.read(playerControllerProvider.notifier).updateTitle(s.id, newBaseName);
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Song renamed to "$newBaseName"')),
        );
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to rename: $e')),
        );
      }
    }
  }

  Future<void> _deleteFile(Song s) async {
    try {
      // For MediaStore songs, we can't directly delete the file
      // This would require special permissions and MediaStore API
      // For now, we'll just show a message that deletion is not supported
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('File deletion not supported for MediaStore songs'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete: $e')),
        );
      }
    }
  }

  Future<void> _saveArtistOverride(Song s, String newArtist) async {
    // store override via MetadataOverridesService
    final service = OverridesService.instance;
    await service.setArtistOverride(s.id, newArtist);
  }
}


