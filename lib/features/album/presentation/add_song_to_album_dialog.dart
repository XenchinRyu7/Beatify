import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../domain/entities/album.dart';
import '../../../domain/entities/song.dart';
import '../../../domain/repositories/song_repository.dart';
import '../../player/application/player_controller.dart';
import '../application/album_controller.dart';

class AddSongToAlbumDialog extends ConsumerStatefulWidget {
  final Album album;

  const AddSongToAlbumDialog({super.key, required this.album});

  @override
  ConsumerState<AddSongToAlbumDialog> createState() => _AddSongToAlbumDialogState();
}

class _AddSongToAlbumDialogState extends ConsumerState<AddSongToAlbumDialog> {
  late final SongRepository _songRepository;
  List<Song> _allSongs = [];
  List<Song> _filteredSongs = [];
  List<Song> _selectedSongs = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _songRepository = ref.read(songRepositoryProvider);
    _loadSongs();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSongs() async {
    try {
      final songs = await _songRepository.getAllSongs();
      // Filter out songs that are already in the album
      final albumSongIds = widget.album.songs.map((s) => s.id).toSet();
      final availableSongs = songs.where((song) => !albumSongIds.contains(song.id)).toList();
      
      setState(() {
        _allSongs = availableSongs;
        _filteredSongs = availableSongs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load songs: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _filterSongs(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredSongs = _allSongs;
      } else {
        _filteredSongs = _allSongs.where((song) {
          return song.title.toLowerCase().contains(query.toLowerCase()) ||
                 song.artist.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _toggleSongSelection(Song song) {
    setState(() {
      if (_selectedSongs.contains(song)) {
        _selectedSongs.remove(song);
      } else {
        _selectedSongs.add(song);
      }
    });
  }

  Future<void> _addSelectedSongs() async {
    if (_selectedSongs.isEmpty) return;

    try {
      for (final song in _selectedSongs) {
        await ref
            .read(albumControllerProvider.notifier)
            .addSongToAlbum(widget.album.id, song);
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added ${_selectedSongs.length} song(s) to album'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add songs: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Add Songs to "${widget.album.name}"',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(PhosphorIconsLight.x),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search songs...',
                prefixIcon: const Icon(PhosphorIconsLight.magnifyingGlass),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: _filterSongs,
            ),
            const SizedBox(height: 16),
            if (_selectedSongs.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(PhosphorIconsLight.checkCircle, color: Colors.blue.shade700),
                    const SizedBox(width: 8),
                    Text(
                      '${_selectedSongs.length} song(s) selected',
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredSongs.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                PhosphorIconsLight.musicNote,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _allSongs.isEmpty
                                    ? 'All songs are already in this album'
                                    : 'No songs found',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _filteredSongs.length,
                          itemBuilder: (context, index) {
                            final song = _filteredSongs[index];
                            final isSelected = _selectedSongs.contains(song);
                            
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: isSelected
                                    ? Theme.of(context).colorScheme.primary.withOpacity(0.10)
                                    : Theme.of(context).colorScheme.surface.withOpacity(0.06),
                                border: Border.all(
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.primary.withOpacity(0.20)
                                      : Colors.white.withOpacity(0.06),
                                ),
                              ),
                              child: ListTile(
                                leading: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(6),
                                    color: isSelected
                                        ? Theme.of(context).colorScheme.primary.withOpacity(0.18)
                                        : Theme.of(context).colorScheme.surface.withOpacity(0.12),
                                  ),
                                  child: Icon(
                                    PhosphorIconsLight.musicNote,
                                    color: isSelected
                                        ? Theme.of(context).colorScheme.primary
                                        : Colors.grey.shade400,
                                    size: 20,
                                  ),
                                ),
                                title: Text(
                                  song.title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: isSelected ? Theme.of(context).colorScheme.primary : null,
                                  ),
                                ),
                                subtitle: Text(
                                  song.artist,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Theme.of(context).colorScheme.primary.withOpacity(0.9)
                                        : Colors.grey.shade500,
                                  ),
                                ),
                                trailing: isSelected
                                    ? Icon(
                                        PhosphorIconsLight.checkCircle,
                                        color: Theme.of(context).colorScheme.primary,
                                      )
                                    : const Icon(PhosphorIconsLight.circle),
                                onTap: () => _toggleSongSelection(song),
                              ),
                            );
                          },
                        ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _selectedSongs.isEmpty ? null : _addSelectedSongs,
                    child: Text('Add ${_selectedSongs.length} Song(s)'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
