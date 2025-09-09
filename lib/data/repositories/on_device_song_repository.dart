import 'dart:io';

import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../domain/entities/song.dart';
import '../../domain/repositories/song_repository.dart';

class OnDeviceSongRepository implements SongRepository {
  static const Set<String> _exts = {'.mp3', '.m4a', '.aac', '.flac', '.wav', '.ogg'};

  @override
  Future<List<Song>> getAllSongs() async {
    final dirs = await _candidateDirs();
    final files = <File>[];
    for (final dir in dirs) {
      if (await dir.exists()) {
        files.addAll(await _walk(dir));
      }
    }
    final result = <Song>[];
    for (final f in files) {
      try {
        final meta = await MetadataRetriever.fromFile(f);
        result.add(Song(
          id: f.path.hashCode.toString(),
          title: meta.trackName?.trim().isNotEmpty == true ? meta.trackName! : p.basenameWithoutExtension(f.path),
          artist: meta.trackArtistNames?.join(', ').trim().isNotEmpty == true ? meta.trackArtistNames!.join(', ') : 'Unknown',
          coverUrl: '',
          url: f.uri.toString(),
          audioId: null,
        ));
      } catch (_) {
        // skip invalid file
      }
    }
    return result;
  }

  Future<List<Directory>> _candidateDirs() async {
    final music = await getExternalStorageDirectories(type: StorageDirectory.music) ?? [];
    final downloads = await getExternalStorageDirectories(type: StorageDirectory.downloads) ?? [];
    final movies = await getExternalStorageDirectories(type: StorageDirectory.movies) ?? [];
    final dcim = await getExternalStorageDirectories(type: StorageDirectory.dcim) ?? [];
    return [...music, ...downloads, ...movies, ...dcim];
  }

  Future<List<File>> _walk(Directory dir) async {
    final out = <File>[];
    await for (final entity in dir.list(recursive: true, followLinks: false)) {
      if (entity is File && _exts.contains(p.extension(entity.path).toLowerCase())) {
        out.add(entity);
      }
    }
    return out;
  }
}


