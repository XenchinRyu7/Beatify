import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../home/presentation/home_page.dart';
import '../../library/presentation/library_page.dart';
import '../../album/presentation/album_page.dart';
import '../../settings/presentation/settings_page.dart';
import '../../../widgets/mini_player.dart';

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  int _index = 0;
  final _pages = const [HomePage(), LibraryPage(), AlbumPage(), SettingsPage()];

  @override
  Widget build(BuildContext context) {
    final currentIndex = (_index >= _pages.length) ? 0 : _index;
    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(index: currentIndex, children: _pages),
          const Align(alignment: Alignment.bottomCenter, child: MiniPlayer()),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        destinations: const [
          NavigationDestination(icon: Icon(PhosphorIconsLight.house), label: 'Home'),
          NavigationDestination(icon: Icon(PhosphorIconsLight.musicNote), label: 'Library'),
          NavigationDestination(icon: Icon(PhosphorIconsLight.disc), label: 'Albums'),
          NavigationDestination(icon: Icon(PhosphorIconsLight.gear), label: 'Settings'),
        ],
        onDestinationSelected: (i) => setState(() => _index = i.clamp(0, _pages.length - 1)),
      ),
    );
  }
}


