import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../player/application/player_controller.dart';
import '../../../services/overrides_service.dart';

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
                      IconButton(
                        icon: const Icon(PhosphorIconsLight.dotsThreeOutlineVertical),
                        onPressed: () => _showPlayerMenu(context, ref, song),
                      ),
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
                        value: _clamp01(_progressValue(state)),
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

  double _clamp01(double v) {
    if (v.isNaN || !v.isFinite) return 0;
    if (v < 0) return 0;
    if (v > 1) return 1;
    return v;
  }

  String _formatDuration(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    final minutes = two(d.inMinutes.remainder(60));
    final seconds = two(d.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  Future<String?> _promptText(BuildContext context, String title, String initial) async {
    final ctrl = TextEditingController(text: initial);
    return showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: TextField(controller: ctrl, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(context, ctrl.text), child: const Text('Simpan')),
        ],
      ),
    );
  }

  Future<void> _showSleepTimer(BuildContext context) async {
    Duration? picked;
    await showModalBottomSheet(
      context: context,
      builder: (_) {
        return StatefulBuilder(builder: (context, setState) {
          Duration temp = picked ?? const Duration(minutes: 15);
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Timer tidur'),
                Slider(
                  min: 5,
                  max: 120,
                  value: temp.inMinutes.toDouble(),
                  label: '${temp.inMinutes} menit',
                  onChanged: (v) => setState(() => temp = Duration(minutes: v.toInt())),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
                    ElevatedButton(
                      onPressed: () {
                        picked = temp;
                        Navigator.pop(context);
                      },
                      child: const Text('Setel'),
                    )
                  ],
                )
              ],
            ),
          );
        });
      },
    );
    if (picked != null) {
      // TODO: Integrate with a timer to pause playback after duration
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Timer tidur: ${picked!.inMinutes} menit')));
      }
    }
  }

  void _showPlayerMenu(BuildContext context, WidgetRef ref, dynamic song) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(PhosphorIconsLight.moon),
                title: const Text('Timer tidur'),
                onTap: () async {
                  Navigator.pop(context);
                  final presets = [10, 20, 30, 60, 120, 240];
                  int? chosen;
                  await showModalBottomSheet(
                    context: context,
                    builder: (_) => SafeArea(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (final m in presets)
                            ListTile(
                              title: Text('$m menit'),
                              onTap: () {
                                chosen = m;
                                Navigator.pop(context);
                              },
                            ),
                          ListTile(
                            leading: const Icon(PhosphorIconsLight.clock),
                            title: const Text('Custom...'),
                            onTap: () async {
                              Navigator.pop(context);
                              final v = await _promptText(context, 'Custom (menit)', '30');
                              if (v != null) chosen = int.tryParse(v);
                            },
                          )
                        ],
                      ),
                    ),
                  );
                  if (chosen != null) {
                    ref.read(audioPlayerServiceProvider).scheduleSleep(Duration(minutes: chosen!));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Timer tidur diatur: $chosen menit')));
                    }
                  }
                },
              ),
              ListTile(
                leading: const Icon(PhosphorIconsLight.pencilSimple),
                title: const Text('Ubah info lagu'),
                onTap: () async {
                  Navigator.pop(context);
                  if (song == null) return;
                  final titleCtrl = TextEditingController(text: song.title);
                  final artistCtrl = TextEditingController(text: song.artist);
                  final res = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Ubah info lagu'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Judul')),
                          TextField(controller: artistCtrl, decoration: const InputDecoration(labelText: 'Artis')),
                        ],
                      ),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
                        ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Simpan')),
                      ],
                    ),
                  );
                  if (res == true) {
                    final newTitle = titleCtrl.text.trim();
                    final newArtist = artistCtrl.text.trim();
                    if (newTitle.isNotEmpty) {
                      await OverridesService.instance.setTitleOverride(song.id, newTitle);
                      ref.read(playerControllerProvider.notifier).updateTitle(song.id, newTitle);
                    }
                    if (newArtist.isNotEmpty) {
                      await OverridesService.instance.setArtistOverride(song.id, newArtist);
                      ref.read(playerControllerProvider.notifier).updateArtist(song.id, newArtist);
                    }
                  }
                },
              ),
              ListTile(
                leading: const Icon(PhosphorIconsLight.trash),
                title: const Text('Hapus dari antrian'),
                onTap: () {
                  Navigator.pop(context);
                  if (song == null) return;
                  ref.read(playerControllerProvider.notifier).removeFromQueue(song.id);
                },
              ),
            ],
          ),
        );
      },
    );
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
            final isCurrent = state.currentIndex == index;
            return Dismissible(
              key: ValueKey('dismiss-${s.id}'),
              direction: DismissDirection.endToStart,
              background: Container(
                color: Colors.redAccent,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              onDismissed: (_) => controller.removeFromQueue(s.id),
              child: ListTile(
              key: ValueKey(s.id),
              leading: isCurrent
                  ? const Icon(Icons.graphic_eq)
                  : const Icon(Icons.music_note),
              title: Text(
                s.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: isCurrent ? const TextStyle(fontWeight: FontWeight.w600) : null,
              ),
              subtitle: Text(s.artist, maxLines: 1, overflow: TextOverflow.ellipsis),
              trailing: const Icon(Icons.drag_handle),
              onTap: () => controller.playAt(index),
              ),
            );
          },
        );
      },
    );
  }
}


