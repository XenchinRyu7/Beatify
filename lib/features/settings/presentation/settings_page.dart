import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../services/library_dirs_service.dart';
import '../../../features/player/application/player_controller.dart';
import '../../home/application/library_controller.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final _dirs = LibraryDirsService();
  List<String> _paths = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _paths = await _dirs.getDirectories();
    if (mounted) setState(() {});
  }

  Future<void> _requestPermission() async {
    var ok = await Permission.audio.isGranted;
    if (!ok) ok = (await Permission.audio.request()).isGranted;
    if (!ok) ok = (await Permission.storage.request()).isGranted;
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Izin diperlukan untuk membaca file musik')));
    } else {
      // permission granted → load library so Home gets data
      await ref.read(libraryControllerProvider.notifier).load();
    }
  }

  Future<void> _addFolder() async {
    await _requestPermission();
    final dir = await FilePicker.platform.getDirectoryPath();
    if (dir != null) {
      await _dirs.addDirectory(dir);
      await _load();
    }
  }

  Future<void> _scanNow() async {
    await ref.read(libraryControllerProvider.notifier).load();
    final count = ref.read(libraryControllerProvider).length;
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Scan selesai • Ditemukan $count lagu')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const ListTile(
            title: Text('Pemindaian Lagu'),
            subtitle: Text('Aplikasi akan memindai otomatis saat dibuka. Gunakan tombol di bawah untuk memindai ulang.'),
          ),
          ListTile(
            leading: const Icon(Icons.lock_open),
            title: const Text('Pastikan izin media diizinkan'),
            onTap: _requestPermission,
          ),
          ListTile(
            leading: const Icon(Icons.refresh),
            title: const Text('Scan Sekarang'),
            onTap: _scanNow,
          ),
        ],
      ),
    );
  }
}


