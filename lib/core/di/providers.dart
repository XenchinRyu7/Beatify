import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/filesystem_song_repository.dart';
import '../../domain/repositories/song_repository.dart';
import '../../features/player/application/player_controller.dart';

final overrideProviders = <Override>[
  songRepositoryProvider.overrideWithValue(FilesystemSongRepository()),
];


