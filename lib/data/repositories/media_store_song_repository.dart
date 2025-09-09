import 'package:media_store_plus/media_store_plus.dart';

import '../../domain/entities/song.dart';
import '../../domain/repositories/song_repository.dart';

class MediaStoreSongRepository implements SongRepository {
  final MediaStore _mediaStore = MediaStore();

  @override
  Future<List<Song>> getAllSongs() async {
    final audios = await _mediaStore.getAudio();
    return audios.map((a) => Song(
      id: a.id?.toString() ?? (a.uri ?? ''),
      title: (a.displayName?.trim().isNotEmpty ?? false) ? a.displayName!.trim() : 'Unknown',
      artist: (a.artist?.trim().isNotEmpty ?? false) ? a.artist!.trim() : 'Unknown',
      coverUrl: '',
      url: a.uri ?? '',
      audioId: null,
    )).toList();
  }
}


