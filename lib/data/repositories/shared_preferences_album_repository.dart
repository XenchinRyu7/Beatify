import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/album.dart';
import '../../domain/entities/song.dart';
import '../../domain/repositories/album_repository.dart';

class SharedPreferencesAlbumRepository implements AlbumRepository {
  static const String _albumsKey = 'albums';

  @override
  Future<List<Album>> getAllAlbums() async {
    final prefs = await SharedPreferences.getInstance();
    final albumsJson = prefs.getStringList(_albumsKey) ?? [];
    
    return albumsJson
        .map((json) => Album.fromJson(jsonDecode(json)))
        .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt)); // Sort by newest first
  }

  @override
  Future<Album?> getAlbumById(String id) async {
    final albums = await getAllAlbums();
    try {
      return albums.firstWhere((album) => album.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Album> createAlbum(String name) async {
    final album = Album(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      createdAt: DateTime.now(),
      songs: [],
    );

    await _saveAlbum(album);
    return album;
  }

  @override
  Future<Album> updateAlbum(Album album) async {
    await _saveAlbum(album);
    return album;
  }

  @override
  Future<void> deleteAlbum(String id) async {
    final albums = await getAllAlbums();
    albums.removeWhere((album) => album.id == id);
    await _saveAlbums(albums);
  }

  @override
  Future<Album> addSongToAlbum(String albumId, Song song) async {
    final album = await getAlbumById(albumId);
    if (album == null) {
      throw Exception('Album not found');
    }

    // Check if song already exists in album
    if (album.songs.any((s) => s.id == song.id)) {
      return album;
    }

    final updatedAlbum = album.copyWith(
      songs: [...album.songs, song],
    );

    await _saveAlbum(updatedAlbum);
    return updatedAlbum;
  }

  @override
  Future<Album> removeSongFromAlbum(String albumId, String songId) async {
    final album = await getAlbumById(albumId);
    if (album == null) {
      throw Exception('Album not found');
    }

    final updatedAlbum = album.copyWith(
      songs: album.songs.where((song) => song.id != songId).toList(),
    );

    await _saveAlbum(updatedAlbum);
    return updatedAlbum;
  }

  Future<void> _saveAlbum(Album album) async {
    final albums = await getAllAlbums();
    final existingIndex = albums.indexWhere((a) => a.id == album.id);
    
    if (existingIndex >= 0) {
      albums[existingIndex] = album;
    } else {
      albums.add(album);
    }
    
    await _saveAlbums(albums);
  }

  Future<void> _saveAlbums(List<Album> albums) async {
    final prefs = await SharedPreferences.getInstance();
    final albumsJson = albums
        .map((album) => jsonEncode(album.toJson()))
        .toList();
    
    await prefs.setStringList(_albumsKey, albumsJson);
  }
}
