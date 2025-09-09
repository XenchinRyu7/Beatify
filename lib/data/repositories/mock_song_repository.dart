import 'package:beatify/domain/entities/song.dart';
import 'package:beatify/domain/repositories/song_repository.dart';

class MockSongRepository implements SongRepository {
  @override
  Future<List<Song>> getAllSongs() async {
    return const [
      Song(
        id: '1',
        title: 'Skyline Dreams',
        artist: 'Nova',
        coverUrl: 'https://picsum.photos/seed/beatify1/600/600',
        url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
        audioId: null,
      ),
      Song(
        id: '2',
        title: 'Neon Sunset',
        artist: 'Lumen',
        coverUrl: 'https://picsum.photos/seed/beatify2/600/600',
        url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
        audioId: null,
      ),
      Song(
        id: '3',
        title: 'Midnight Drive',
        artist: 'Aether',
        coverUrl: 'https://picsum.photos/seed/beatify3/600/600',
        url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',
        audioId: null,
      ),
    ];
  }
}


