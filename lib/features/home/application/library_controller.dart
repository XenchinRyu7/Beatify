import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/song.dart';
import '../../../domain/repositories/song_repository.dart';
import '../../player/application/player_controller.dart';

class LibraryController extends Notifier<List<Song>> {
  late final SongRepository _repo;

  @override
  List<Song> build() {
    _repo = ref.read(songRepositoryProvider);
    return const [];
  }

  Future<void> load() async {
    final songs = await _repo.getAllSongs();
    state = songs;
  }
}

final libraryControllerProvider = NotifierProvider<LibraryController, List<Song>>(LibraryController.new);

final librarySearchQueryProvider = StateProvider<String>((ref) => '');


