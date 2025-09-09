import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/theme/app_theme.dart';
import '../../../widgets/glassmorphism_container.dart';
import '../../../widgets/mini_player.dart';
import '../../player/application/player_controller.dart';
import '../application/library_controller.dart';
import '../../../services/permission_service.dart';
import 'search_page.dart';
import '../../player/presentation/player_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await ref.read(audioPlayerServiceProvider).init();
      // Auto request permission, then scan default music/downloads dirs
      await PermissionService().ensureAudioPermission();
      await ref.read(libraryControllerProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final library = ref.watch(libraryControllerProvider);
    final query = ref.watch(librarySearchQueryProvider);
    final filtered = query.isEmpty
        ? library
        : library.where((s) => s.title.toLowerCase().contains(query.toLowerCase()) || s.artist.toLowerCase().contains(query.toLowerCase())).toList();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Beatify'),
        actions: [
          IconButton(
            icon: const Icon(PhosphorIconsLight.magnifyingGlass),
            onPressed: () {
              Navigator.of(context).push(_fadeRoute(const SearchPage()));
            },
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(gradient: AppGradients.primary),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.82,
                ),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final song = filtered[index];
                  return GestureDetector(
                    onTap: () async {
                      final baseList = filtered;
                      ref.read(playerControllerProvider.notifier).setPlaylist(baseList, startIndex: index);
                      if (!mounted) return;
                      Navigator.of(context).push(_fadeRoute(const PlayerPage()));
                    },
                    child: GlassmorphismContainer(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      borderRadius: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: Image.network(
                                  song.coverUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: Colors.white12,
                                    child: const Center(child: Icon(Icons.music_note, size: 40)),
                                  ),
                                  loadingBuilder: (context, child, progress) {
                                    if (progress == null) return child;
                                    return Container(
                                      color: Colors.white12,
                                      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            song.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            song.artist,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const Align(alignment: Alignment.bottomCenter, child: MiniPlayer()),
        ],
      ),
    );
  }

  Route _fadeRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) => FadeTransition(opacity: animation, child: child),
    );
  }
}

class _SongSearchDelegate extends SearchDelegate<String?> {
  _SongSearchDelegate({String? initial}) {
    query = initial ?? '';
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(onPressed: () => query = '', icon: const Icon(Icons.clear))
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(onPressed: () => close(context, null), icon: const Icon(Icons.arrow_back));
  }

  @override
  Widget buildResults(BuildContext context) {
    close(context, query);
    return const SizedBox.shrink();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return const SizedBox.shrink();
  }
}


