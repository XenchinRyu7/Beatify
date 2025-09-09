import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/album.dart';
import '../../../domain/entities/song.dart';
import '../../../domain/repositories/album_repository.dart';
import '../../../data/repositories/shared_preferences_album_repository.dart';

// Provider untuk AlbumRepository
final albumRepositoryProvider = Provider<AlbumRepository>((ref) {
  return SharedPreferencesAlbumRepository();
});

// State untuk daftar album
class AlbumListState {
  final List<Album> albums;
  final bool isLoading;
  final String? error;

  const AlbumListState({
    this.albums = const [],
    this.isLoading = false,
    this.error,
  });

  AlbumListState copyWith({
    List<Album>? albums,
    bool? isLoading,
    String? error,
  }) {
    return AlbumListState(
      albums: albums ?? this.albums,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Controller untuk mengelola state album
class AlbumController extends StateNotifier<AlbumListState> {
  final AlbumRepository _albumRepository;

  AlbumController(this._albumRepository) : super(const AlbumListState()) {
    loadAlbums();
  }

  Future<void> loadAlbums() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final albums = await _albumRepository.getAllAlbums();
      state = state.copyWith(albums: albums, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load albums: $e',
      );
    }
  }

  Future<void> createAlbum(String name) async {
    try {
      final album = await _albumRepository.createAlbum(name);
      state = state.copyWith(
        albums: [album, ...state.albums],
      );
    } catch (e) {
      state = state.copyWith(error: 'Failed to create album: $e');
    }
  }

  Future<void> deleteAlbum(String albumId) async {
    try {
      await _albumRepository.deleteAlbum(albumId);
      state = state.copyWith(
        albums: state.albums.where((album) => album.id != albumId).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: 'Failed to delete album: $e');
    }
  }

  Future<void> addSongToAlbum(String albumId, Song song) async {
    try {
      final updatedAlbum = await _albumRepository.addSongToAlbum(albumId, song);
      final updatedAlbums = state.albums.map((album) {
        return album.id == albumId ? updatedAlbum : album;
      }).toList();
      state = state.copyWith(albums: updatedAlbums);
    } catch (e) {
      state = state.copyWith(error: 'Failed to add song to album: $e');
    }
  }

  Future<void> removeSongFromAlbum(String albumId, String songId) async {
    try {
      final updatedAlbum = await _albumRepository.removeSongFromAlbum(albumId, songId);
      final updatedAlbums = state.albums.map((album) {
        return album.id == albumId ? updatedAlbum : album;
      }).toList();
      state = state.copyWith(albums: updatedAlbums);
    } catch (e) {
      state = state.copyWith(error: 'Failed to remove song from album: $e');
    }
  }

  Future<void> updateAlbumName(String albumId, String newName) async {
    try {
      final album = await _albumRepository.getAlbumById(albumId);
      if (album == null) {
        state = state.copyWith(error: 'Album not found');
        return;
      }

      final updatedAlbum = album.copyWith(name: newName);
      await _albumRepository.updateAlbum(updatedAlbum);
      
      final updatedAlbums = state.albums.map((album) {
        return album.id == albumId ? updatedAlbum : album;
      }).toList();
      state = state.copyWith(albums: updatedAlbums);
    } catch (e) {
      state = state.copyWith(error: 'Failed to update album name: $e');
    }
  }
}

// Provider untuk AlbumController
final albumControllerProvider = StateNotifierProvider<AlbumController, AlbumListState>((ref) {
  final albumRepository = ref.watch(albumRepositoryProvider);
  return AlbumController(albumRepository);
});

// Provider untuk mendapatkan album berdasarkan ID
final albumByIdProvider = Provider.family<Album?, String>((ref, albumId) {
  final albums = ref.watch(albumControllerProvider).albums;
  try {
    return albums.firstWhere((album) => album.id == albumId);
  } catch (e) {
    return null;
  }
});
