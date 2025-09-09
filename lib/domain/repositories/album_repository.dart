import '../entities/album.dart';
import '../entities/song.dart';

abstract class AlbumRepository {
  Future<List<Album>> getAllAlbums();
  Future<Album?> getAlbumById(String id);
  Future<Album> createAlbum(String name);
  Future<Album> updateAlbum(Album album);
  Future<void> deleteAlbum(String id);
  Future<Album> addSongToAlbum(String albumId, Song song);
  Future<Album> removeSongFromAlbum(String albumId, String songId);
}
