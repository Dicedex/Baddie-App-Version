import 'package:audioplayers/audioplayers.dart';

class RingtoneService {
  static final _player = AudioPlayer();

  static Future<void> play() async {
    await _player.setReleaseMode(ReleaseMode.loop);
    await _player.play(
      AssetSource('sounds/ringtone.mp3'),
      volume: 1.0,
    );
  }

  static Future<void> stop() async {
    await _player.stop();
  }
}
