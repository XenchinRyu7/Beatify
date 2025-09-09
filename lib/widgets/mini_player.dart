import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../features/player/application/player_controller.dart';
import 'glassmorphism_container.dart';
import '../features/player/presentation/player_page.dart';

class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(playerControllerProvider);
    final controller = ref.read(playerControllerProvider.notifier);
    final song = state.currentSong;
    final show = song != null;

    if (!show) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(12),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(PageRouteBuilder(
            pageBuilder: (_, __, ___) => const PlayerPage(),
            transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
          ));
        },
        child: GlassmorphismContainer(
          borderRadius: 18,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(PhosphorIconsLight.skipBack),
                onPressed: controller.previous,
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  song!.coverUrl,
                  width: 44,
                  height: 44,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(width: 44, height: 44, color: Colors.white12, child: const Icon(Icons.music_note)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(song.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    LinearProgressIndicator(
                      value: _progressValue(state),
                      backgroundColor: Colors.white24,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(state.isPlaying ? PhosphorIconsFill.pause : PhosphorIconsFill.play),
                onPressed: controller.togglePlayPause,
              )
              ,
              IconButton(
                icon: const Icon(PhosphorIconsLight.skipForward),
                onPressed: controller.next,
              )
            ],
          ),
        ),
      ),
    );
  }

  double _progressValue(PlayerViewState state) {
    final total = (state.duration ?? Duration.zero).inMilliseconds;
    if (total == 0) return 0;
    return state.position.inMilliseconds / total;
  }
}


