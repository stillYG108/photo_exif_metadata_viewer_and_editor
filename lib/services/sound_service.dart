import 'package:audioplayers/audioplayers.dart';

/// Service to handle global sound effects
/// Using Singleton pattern to ensure only one audio player instance exists
class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  final AudioPlayer _player = AudioPlayer();
  
  // Cache the player mode for lower latency
  bool _initialized = false;

  /// Initialize the sound service
  Future<void> init() async {
    if (_initialized) return;
    
    // Set to low latency mode for UI sounds
    await _player.setReleaseMode(ReleaseMode.stop);
    
    // Preload the sound
    // Note: AudioCache is now built into AudioPlayer in version 6.0.0+
    // We can just set the source to preload it
    await _player.setSource(AssetSource('mixkit-sci-fi-click-900.wav'));
    
    _initialized = true;
  }

  /// Play the standard button click sound
  Future<void> playClickSound() async {
    try {
      // In newer audioplayers versions, we create a new player for overlapping sounds
      // or stop and restart. For UI clicks, overlapping is better.
      // But for simplicity and performance, we'll try to use one player first.
      
      if (_player.state == PlayerState.playing) {
         await _player.stop();
      }
      
      await _player.play(AssetSource('mixkit-sci-fi-click-900.wav'), volume: 0.5);
    } catch (e) {
      print('Error playing sound: $e');
    }
  }
}
