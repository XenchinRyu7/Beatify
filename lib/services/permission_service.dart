import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  Future<bool> ensureAudioPermission() async {
    if (await Permission.audio.isGranted) return true;
    // Android 13+: READ_MEDIA_AUDIO
    final status = await Permission.audio.request();
    if (status.isGranted) return true;
    // Fallback: storage (older devices)
    final storage = await Permission.storage.request();
    return storage.isGranted;
  }
}


