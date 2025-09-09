import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../services/library_dirs_service.dart';
import '../../services/overrides_service.dart';

import '../../domain/entities/song.dart';
import '../../domain/repositories/song_repository.dart';

class FilesystemSongRepository implements SongRepository {
  static const Set<String> _exts = {'.mp3', '.m4a', '.aac', '.flac', '.wav', '.ogg'};
  final LibraryDirsService libraryDirsService;

  FilesystemSongRepository({LibraryDirsService? libraryDirsService})
      : libraryDirsService = libraryDirsService ?? LibraryDirsService();

  @override
  Future<List<Song>> getAllSongs() async {
    final userDirs = await libraryDirsService.getDirectories();
    final dirs = userDirs.isEmpty ? await _candidateDirs() : userDirs.map((e) => Directory(e)).toList();
    final files = <File>[];
    for (final dir in dirs) {
      if (await dir.exists()) {
        files.addAll(await _walk(dir));
      }
    }
    final overrides = OverridesService.instance;
    final result = <Song>[];
    for (final f in files) {
      final base = p.basenameWithoutExtension(f.path);
      final id = f.path.hashCode.toString();
      final artistOverride = await overrides.getArtistOverride(id);
      result.add(Song(
        id: id,
        title: base,
        artist: (artistOverride == null || artistOverride.isEmpty) ? 'Unknown' : artistOverride,
        coverUrl: '',
        url: 'file://${f.path}',
        audioId: null,
      ));
    }
    return result;
  }

  Future<List<Directory>> _candidateDirs() async {
    final music = await getExternalStorageDirectories(type: StorageDirectory.music) ?? [];
    final downloads = await getExternalStorageDirectories(type: StorageDirectory.downloads) ?? [];
    return [...music, ...downloads];
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


