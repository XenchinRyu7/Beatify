import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../../core/theme/app_theme.dart';
import '../../../widgets/glassmorphism_container.dart';
import '../../../widgets/mini_player.dart';
import '../../player/application/player_controller.dart';
import '../application/library_controller.dart';
import '../../../services/permission_service.dart';
import 'search_page.dart';
import '../../player/presentation/player_page.dart';
import '../../album/presentation/album_page.dart';
import '../../album/presentation/album_detail_page.dart';
import '../../album/application/album_controller.dart';

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
    final albumState = ref.watch(albumControllerProvider);
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
          Container(color: Colors.black.withOpacity(0.40)),
          SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                await ref.read(libraryControllerProvider.notifier).load();
                await ref.read(albumControllerProvider.notifier).loadAlbums();
              },
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Albums', style: Theme.of(context).textTheme.titleLarge),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          PageRouteBuilder(
                            pageBuilder: (_, __, ___) => const AlbumPage(),
                            transitionsBuilder: (_, animation, __, child) => FadeTransition(opacity: animation, child: child),
                          ),
                        );
                      },
                      child: const Text('See all', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                albumState.albums.isEmpty
                    ? Container(
                        height: 150,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Theme.of(context).colorScheme.surface.withOpacity(0.05),
                          border: Border.all(color: Colors.white.withOpacity(0.05)),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                PhosphorIconsLight.disc,
                                size: 40,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'No albums yet',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : MasonryGridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        itemCount: albumState.albums.length > 4 ? 4 : albumState.albums.length,
                        itemBuilder: (context, index) {
                          final album = albumState.albums[index];
                          return _buildHomeAlbumCard(context, album);
                        },
                      ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Songs', style: Theme.of(context).textTheme.titleLarge),
                    Text('${filtered.length}')
                  ],
                ),
                const SizedBox(height: 10),
                ...filtered.map((song) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Theme.of(context).colorScheme.surface.withOpacity(0.10),
                    border: Border.all(color: Colors.white.withOpacity(0.10)),
                  ),
                  child: ListTile(
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.16),
                      ),
                      child: Icon(PhosphorIconsLight.musicNote, color: Theme.of(context).colorScheme.primary),
                    ),
                    title: Text(
                      song.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    subtitle: Text(
                      song.artist,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70),
                    ),
                    onTap: () async {
                      final baseList = filtered;
                      ref.read(playerControllerProvider.notifier).setPlaylist(baseList, startIndex: filtered.indexOf(song));
                      if (!mounted) return;
                      Navigator.of(context).push(_fadeRoute(const PlayerPage()));
                    },
                  ),
                )),
              ],
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

  Widget _buildHomeAlbumCard(BuildContext context, dynamic album) {
    // Calculate dynamic height based on album name length
    final nameLength = album.name.length;
    final baseHeight = 140.0;
    final extraHeight = (nameLength > 20) ? 30.0 : (nameLength > 15) ? 15.0 : 0.0;
    final cardHeight = baseHeight + extraHeight;
    
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => AlbumDetailPage(album: album),
            transitionsBuilder: (_, animation, __, child) => FadeTransition(opacity: animation, child: child),
          ),
        );
      },
      child: Container(
        height: cardHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Theme.of(context).colorScheme.surface.withOpacity(0.10),
          border: Border.all(color: Colors.white.withOpacity(0.10)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              PhosphorIconsLight.disc,
              size: 40,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 8),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  album.name,
                  maxLines: nameLength > 20 ? 3 : 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${album.songs.length} songs',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
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


