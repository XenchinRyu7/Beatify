import 'package:flutter/services.dart';

import '../../domain/entities/song.dart';
import '../../domain/repositories/song_repository.dart';
import '../../services/overrides_service.dart';

class MediaStoreSongRepository implements SongRepository {
  static const MethodChannel _channel = MethodChannel('beatify/media_store');

  @override
  Future<List<Song>> getAllSongs() async {
    final List<dynamic> items = await _channel.invokeMethod('getAudio');
    final overrides = OverridesService.instance;
    final List<Song> out = [];
    for (final raw in items) {
      final map = Map<String, dynamic>.from(raw as Map);
      final id = map['id']?.toString() ?? '';
      final title = (map['displayName'] as String?)?.trim() ?? 'Unknown';
      final artist = (map['artist'] as String?)?.trim() ?? 'Unknown';
      final uri = map['uri']?.toString() ?? '';

      final titleOverride = await overrides.getTitleOverride(id);
      final artistOverride = await overrides.getArtistOverride(id);

      out.add(Song(
        id: id,
        title: (titleOverride == null || titleOverride.isEmpty) ? title : titleOverride,
        artist: (artistOverride == null || artistOverride.isEmpty) ? artist : artistOverride,
        coverUrl: '',
        url: uri,
        audioId: null,
      ));
    }
    return out;
  }
}


