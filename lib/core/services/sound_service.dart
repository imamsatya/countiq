import 'package:flutter/services.dart';
import '../../data/datasources/local_database.dart';

/// Lightweight sound & haptic feedback service.
/// Uses system sounds and haptic feedback for cross-platform compatibility.
class SoundService {
  SoundService._();
  static final instance = SoundService._();

  // Sound effects can be added later with audioplayers package
  // bool get _soundEnabled => LocalDatabase.instance.getSoundEnabled();
  bool get _hapticEnabled => LocalDatabase.instance.getHapticEnabled();

  /// Light tap feedback (number/operator selection)
  void tap() {
    if (_hapticEnabled) HapticFeedback.lightImpact();
  }

  /// Selection click (operator picked)
  void select() {
    if (_hapticEnabled) HapticFeedback.selectionClick();
  }

  /// Success vibration (puzzle solved!)
  void success() {
    if (_hapticEnabled) HapticFeedback.heavyImpact();
  }

  /// Error vibration (invalid move)
  void error() {
    if (_hapticEnabled) HapticFeedback.mediumImpact();
  }

  /// Undo/Reset vibration
  void undo() {
    if (_hapticEnabled) HapticFeedback.lightImpact();
  }
}
