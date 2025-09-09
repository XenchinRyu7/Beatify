import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart' show ProcessingState;

import '../../../domain/entities/song.dart';
import '../../../domain/repositories/song_repository.dart';
import '../../../services/audio_player_service.dart';

class PlayerViewState {
  final List<Song> playlist;
  final int? currentIndex;
  final bool isPlaying;
  final Duration position;
  final Duration? duration;

  const PlayerViewState({
    required this.playlist,
    required this.currentIndex,
    required this.isPlaying,
    required this.position,
    required this.duration,
  });

  Song? get currentSong => currentIndex == null ? null : playlist[currentIndex!];

  PlayerViewState copyWith({
    List<Song>? playlist,
    int? currentIndex,
    bool? isPlaying,
    Duration? position,
    Duration? duration,
  }) => PlayerViewState(
        playlist: playlist ?? this.playlist,
        currentIndex: currentIndex ?? this.currentIndex,
        isPlaying: isPlaying ?? this.isPlaying,
        position: position ?? this.position,
        duration: duration ?? this.duration,
      );

  static const empty = PlayerViewState(
    playlist: [],
    currentIndex: null,
    isPlaying: false,
    position: Duration.zero,
    duration: null,
  );
}

final audioPlayerServiceProvider = Provider<AudioPlayerService>((ref) {
  final service = AudioPlayerService();
  // Lazy init; caller should invoke init once at app start
  return service;
});

final songRepositoryProvider = Provider<SongRepository>((ref) => throw UnimplementedError('Provide a SongRepository in main'));

class PlayerController extends Notifier<PlayerViewState> {
  late final AudioPlayerService _audio;
  late final SongRepository _repo;

  @override
  PlayerViewState build() {
    _audio = ref.read(audioPlayerServiceProvider);
    _repo = ref.read(songRepositoryProvider);

    _audio.positionStream.listen((pos) => state = state.copyWith(position: pos));
    _audio.playerStateStream.listen((playerState) {
      final processing = playerState.processingState;
      final playing = playerState.playing;
      if (processing == ProcessingState.completed) {
        state = state.copyWith(isPlaying: false, position: Duration.zero);
      } else {
        state = state.copyWith(isPlaying: playing);
      }
    });
    _audio.durationStream.listen((d) => state = state.copyWith(duration: d));

    return PlayerViewState.empty;
  }

  Future<int> load() async {
    final songs = await _repo.getAllSongs();
    state = state.copyWith(playlist: songs);
    return songs.length;
  }

  Future<void> playAt(int index) async {
    if (index < 0 || index >= state.playlist.length) return;
    state = state.copyWith(currentIndex: index);
    await _audio.setSong(state.playlist[index]);
    await _audio.play();
  }

  Future<void> togglePlayPause() async {
    if (state.isPlaying) {
      await _audio.pause();
    } else {
      await _audio.play();
    }
  }

  Future<void> seek(double value) async {
    final duration = state.duration ?? Duration.zero;
    final target = Duration(milliseconds: (duration.inMilliseconds * value).toInt());
    await _audio.seek(target);
  }

  Future<void> next() async {
    if (state.currentIndex == null) return;
    final nextIndex = (state.currentIndex! + 1) % state.playlist.length;
    await playAt(nextIndex);
  }

  Future<void> previous() async {
    if (state.currentIndex == null) return;
    final prevIndex = (state.currentIndex! - 1 + state.playlist.length) % state.playlist.length;
    await playAt(prevIndex);
  }

  void reorder(int oldIndex, int newIndex) {
    final list = List<Song>.from(state.playlist);
    if (newIndex > oldIndex) newIndex -= 1;
    final moved = list.removeAt(oldIndex);
    list.insert(newIndex, moved);

    int? newCurrent = state.currentIndex;
    if (state.currentIndex != null) {
      if (oldIndex == state.currentIndex) {
        newCurrent = newIndex;
      } else {
        if (oldIndex < state.currentIndex! && newIndex >= state.currentIndex!) {
          newCurrent = state.currentIndex! - 1;
        } else if (oldIndex > state.currentIndex! && newIndex <= state.currentIndex!) {
          newCurrent = state.currentIndex! + 1;
        }
      }
    }

    state = state.copyWith(playlist: list, currentIndex: newCurrent);
  }

  void updateArtist(String songId, String newArtist) {
    final updated = state.playlist.map((s) {
      if (s.id == songId) {
        return Song(
          id: s.id,
          title: s.title,
          artist: newArtist,
          coverUrl: s.coverUrl,
          url: s.url,
          audioId: s.audioId,
        );
      }
      return s;
    }).toList();
    state = state.copyWith(playlist: updated);
  }
}

final playerControllerProvider = NotifierProvider<PlayerController, PlayerViewState>(PlayerController.new);


