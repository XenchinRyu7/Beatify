import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/album.dart';
import '../../../domain/entities/song.dart';
import '../application/album_controller.dart';
import 'add_song_to_album_dialog.dart';

class AlbumDetailPage extends ConsumerWidget {
  final Album album;

  const AlbumDetailPage({super.key, required this.album});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(albumByIdProvider(album.id)) ?? album;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          current.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _showAlbumOptionsBottomSheet(context, ref, current),
            icon: const Icon(PhosphorIconsLight.dotsThreeVertical),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildAlbumHeader(context, current),
          Expanded(
            child: current.songs.isEmpty
                ? _buildEmptyState(context, ref, current)
                : _buildSongsList(context, ref, current),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSongDialog(context, ref, current),
        child: const Icon(PhosphorIconsLight.plus),
      ),
    );
  }

  Widget _buildAlbumHeader(BuildContext context, Album album) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.08),
            Theme.of(context).colorScheme.primary.withOpacity(0.04),
          ],
        ),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
            ),
            child: Icon(
              PhosphorIconsLight.disc,
              size: 40,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  album.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${album.songs.length} songs',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Created ${_formatDate(album.createdAt)}',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref, Album album) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            PhosphorIconsLight.musicNote,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 24),
          Text(
            'No Songs in Album',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add songs to this album to get started',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => _showAddSongDialog(context, ref, album),
            icon: const Icon(PhosphorIconsLight.plus),
            label: const Text('Add Songs'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSongsList(BuildContext context, WidgetRef ref, Album album) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: album.songs.length,
      itemBuilder: (context, index) {
        final song = album.songs[index];
        return _buildSongTile(context, ref, album, song);
      },
    );
  }

  Widget _buildSongTile(BuildContext context, WidgetRef ref, Album album, Song song) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
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
          song.title,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          song.artist,
          style: TextStyle(
            color: Colors.grey.shade600,
          ),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'remove') {
              _removeSongFromAlbum(context, ref, album, song);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'remove',
              child: Row(
                children: [
                  Icon(PhosphorIconsLight.minus, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Remove from Album', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
        onTap: () {},
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'today';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return 'on ${date.day}/${date.month}/${date.year}';
    }
  }

  void _showAddSongDialog(BuildContext context, WidgetRef ref, Album album) {
    showDialog(
      context: context,
      builder: (context) => AddSongToAlbumDialog(album: album),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.95),
        title: const Text('Delete Album'),
        content: Text('Are you sure you want to delete "${album.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back to albums page
              ref.read(albumControllerProvider.notifier).deleteAlbum(album.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Album "${album.name}" deleted'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _removeSongFromAlbum(BuildContext context, WidgetRef ref, Album album, Song song) {
    ref.read(albumControllerProvider.notifier).removeSongFromAlbum(album.id, song.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Removed "${song.title}" from album'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _showAlbumOptionsBottomSheet(BuildContext context, WidgetRef ref, Album album) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.95),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Album Options',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                ),
                child: Icon(
                  PhosphorIconsLight.pencil,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              title: const Text('Edit Album Info'),
              subtitle: const Text('Change album name'),
              onTap: () {
                Navigator.pop(context);
                _showEditAlbumDialog(context, ref, album);
              },
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.red.withOpacity(0.12),
                ),
                child: const Icon(
                  PhosphorIconsLight.trash,
                  color: Colors.red,
                ),
              ),
              title: const Text('Delete Album', style: TextStyle(color: Colors.red)),
              subtitle: const Text('Permanently delete this album'),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(context, ref);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showEditAlbumDialog(BuildContext context, WidgetRef ref, Album album) {
    final controller = TextEditingController(text: album.name);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.95),
        title: const Text('Edit Album'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Album Name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty && newName != album.name) {
                ref.read(albumControllerProvider.notifier).updateAlbumName(album.id, newName);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Album renamed to "$newName"'),
                  ),
                );
              } else {
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
