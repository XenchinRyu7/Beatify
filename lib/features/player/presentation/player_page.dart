import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../player/application/player_controller.dart';

class PlayerPage extends ConsumerWidget {
  const PlayerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(playerControllerProvider);
    final controller = ref.read(playerControllerProvider.notifier);
    final song = state.currentSong;
    final isShuffling = false; // placeholder UI state
    final isRepeating = false; // placeholder UI state

    return Scaffold(
      body: Stack(
        children: [
          if (song != null)
            Positioned.fill(
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                child: Image.network(song.coverUrl, fit: BoxFit.cover),
              ),
            ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(PhosphorIconsLight.caretLeft),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const Spacer(),
                      const Text('Now Playing'),
                      const Spacer(),
                      const SizedBox(width: 48),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (song != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: (song.coverUrl.isEmpty || !song.coverUrl.startsWith('http'))
                            ? Container(color: Colors.white12, child: const Center(child: Icon(Icons.music_note, size: 64)))
                            : Image.network(
                                song.coverUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(color: Colors.white12, child: const Center(child: Icon(Icons.music_note, size: 64))),
                              ),
                      ),
                    ),
                  const SizedBox(height: 24),
                  if (song != null) ...[
                    Text(song.title, style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 6),
                    Text(song.artist, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70)),
                  ],
                  const Spacer(),
                  Column(
                    children: [
                      Slider(
                        value: _progressValue(state),
                        onChanged: (v) => controller.seek(v),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_formatDuration(state.position)),
                          Text(_formatDuration(state.duration ?? Duration.zero)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(PhosphorIconsLight.shuffle),
                            onPressed: () {},
                          ),
                          IconButton(
                            iconSize: 36,
                            icon: const Icon(PhosphorIconsLight.skipBack),
                            onPressed: controller.previous,
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: controller.togglePlayPause,
                            style: ElevatedButton.styleFrom(shape: const CircleBorder(), padding: const EdgeInsets.all(18)),
                            child: Icon(state.isPlaying ? PhosphorIconsFill.pause : PhosphorIconsFill.play, size: 32),
                          ),
                          const SizedBox(width: 16),
                          IconButton(
                            iconSize: 36,
                            icon: const Icon(PhosphorIconsLight.skipForward),
                            onPressed: controller.next,
                          ),
                          IconButton(
                            icon: Icon(PhosphorIconsLight.arrowsClockwise),
                            onPressed: () {},
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            showDragHandle: true,
                            isScrollControlled: true,
                            builder: (_) => _UpNextSheet(),
                          );
                        },
                        icon: const Icon(PhosphorIconsLight.list),
                        label: const Text('Berikutnya'),
                      )
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  double _progressValue(PlayerViewState state) {
    final total = (state.duration ?? Duration.zero).inMilliseconds;
    if (total == 0) return 0;
    return state.position.inMilliseconds / total;
  }

  String _formatDuration(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    final minutes = two(d.inMinutes.remainder(60));
    final seconds = two(d.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}

class _UpNextSheet extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(playerControllerProvider);
    final controller = ref.read(playerControllerProvider.notifier);
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.95,
      minChildSize: 0.3,
      builder: (context, scrollController) {
        return ReorderableListView.builder(
          padding: const EdgeInsets.only(bottom: 24),
          itemCount: state.playlist.length,
          onReorder: controller.reorder,
          itemBuilder: (context, index) {
            final s = state.playlist[index];
            return ListTile(
              key: ValueKey(s.id),
              leading: Text('${index + 1}'),
              title: Text(s.title, maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Text(s.artist, maxLines: 1, overflow: TextOverflow.ellipsis),
              trailing: const Icon(Icons.drag_handle),
              onTap: () => controller.playAt(index),
            );
          },
        );
      },
    );
  }
}


