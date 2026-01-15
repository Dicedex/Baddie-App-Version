import 'dart:io';
import 'package:record/record.dart';
import 'package:firebase_storage/firebase_storage.dart';

class VoiceService {
  final _recorder = AudioRecorder();
  final _storage = FirebaseStorage.instance;

  Future<void> start() async {
    if (await _recorder.hasPermission()) {
      await _recorder.start(const RecordConfig(), path: 'voice.m4a');
    }
  }

  Future<String?> stopAndUpload(String chatId) async {
    final path = await _recorder.stop();
    if (path == null) return null;

    final file = File(path);
    final ref = _storage.ref('voices/$chatId/${DateTime.now().millisecondsSinceEpoch}.m4a');

    await ref.putFile(file);
    return await ref.getDownloadURL();
  }
}
