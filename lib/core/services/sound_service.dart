import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import '../../data/datasources/local_database.dart';

/// Audio & haptic feedback service for CountiQ.
/// Uses same sound files as CryptiQ: pop.mp3, success.mp3, error.mp3
class SoundService {
  SoundService._();
  static final SoundService instance = SoundService._();

  final AudioPlayer _player = AudioPlayer();

  bool get _soundEnabled => LocalDatabase.instance.getSoundEnabled();
  bool get _hapticEnabled => LocalDatabase.instance.getHapticEnabled();

  /// Tap sound (number/operator selection)
  Future<void> playTap() async {
    if (_soundEnabled) {
      await _player.play(AssetSource('audio/pop.mp3'));
    }
    if (_hapticEnabled) HapticFeedback.lightImpact();
  }

  /// Success sound (puzzle solved!)
  Future<void> playSuccess() async {
    if (_soundEnabled) {
      await _player.play(AssetSource('audio/success.mp3'));
    }
    if (_hapticEnabled) HapticFeedback.heavyImpact();
  }

  /// Three-star celebration (double success)
  Future<void> playThreeStar() async {
    if (_soundEnabled) {
      await _player.play(AssetSource('audio/success.mp3'));
      await Future.delayed(const Duration(milliseconds: 200));
      await _player.play(AssetSource('audio/success.mp3'));
    }
    if (_hapticEnabled) HapticFeedback.heavyImpact();
  }

  /// Achievement unlock sound
  Future<void> playAchievement() async {
    if (_soundEnabled) {
      await _player.play(AssetSource('audio/success.mp3'));
    }
    if (_hapticEnabled) HapticFeedback.mediumImpact();
  }

  /// Error sound (invalid operation)
  Future<void> playError() async {
    if (_soundEnabled) {
      await _player.play(AssetSource('audio/error.mp3'));
    }
    if (_hapticEnabled) HapticFeedback.mediumImpact();
  }

  /// Selection haptic only (operator picked)
  void select() {
    if (_hapticEnabled) HapticFeedback.selectionClick();
  }

  /// Undo/Reset haptic only
  void undo() {
    if (_hapticEnabled) HapticFeedback.lightImpact();
  }

  void dispose() {
    _player.dispose();
  }
}
