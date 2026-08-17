// progress_manager.dart
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

class ProgressManager {
  static double _progress = 0.0;
  static Timer? _progressTimer;
  static Timer? _timeoutTimer;
  static VoidCallback? onTimeout;
  static bool _isLoading = false;
  static bool _isCompleted = false;
  static final Random _random = Random();

  // Configuration
  static Duration _timeoutDuration = const Duration(seconds: 30);
  static Duration _progressInterval = const Duration(milliseconds: 250);
  static double _progressIncrement = 0.02;
  static double _maxSimulatedProgress = 0.9;

  static bool startLoading({
    VoidCallback? onTimeout,
    Duration? timeoutDuration,
  }) {
    if (_isLoading && !_isCompleted) {
      return false;
    }

    _reset();
    // _progress = 0.0;
    _isLoading = true;
    _isCompleted = false;
    onTimeout = onTimeout;

    if (timeoutDuration != null) {
      _timeoutDuration = timeoutDuration;
    }

    // Start timeout timer
    _timeoutTimer = Timer(_timeoutDuration, () {
      if (_isLoading) {
        _handleTimeout();
      }
    });

    // Simulate progress
    _progressTimer = Timer.periodic(_progressInterval, (timer) {
      if (_isLoading && _progress < _maxSimulatedProgress) {
        // Add some randomness to make it look more natural
        final randomIncrement =
            _progressIncrement * (0.8 + _random.nextDouble() * 0.4);
        _progress = min(_progress + randomIncrement, _maxSimulatedProgress);
      }
    });
    return true;
  }

  static void completeLoading() {
    if (!_isLoading) {
      return;
    }
    _isCompleted = true;
    _progress = 1.0;
    _progressTimer?.cancel();
    _timeoutTimer?.cancel();

    // Wait a moment to show 100%
    Future.delayed(
      const Duration(milliseconds: 300),
    );
    // Reset after showing completion
    _reset();
  }

  static void stopLoading() {
    if (!_isLoading) {
      return;
    }
    _reset();
  }

  /// Update progress manually (if you have actual progress data)
  /// Returns true if update was applied, false if not loading
  static bool updateProgress(double newProgress) {
    if (!_isLoading) {
      return false;
    }

    // Validate progress value
    if (newProgress < 0 || newProgress > 1) {
      return false;
    }

    _progress = newProgress.clamp(0.0, 1.0);

    // If progress reaches 1, mark as completed
    if (_progress >= 1.0) {
      _isCompleted = true;
    }

    return true;
  }

  /// Check if loading is currently active
  static bool get isLoading => _isLoading;

  /// Check if loading has been marked as completed
  static bool get isCompleted => _isCompleted;

  /// Get current progress (0.0 to 1.0)
  static double get progress => _progress;

  /// Get estimated time remaining (rough estimation)
  static Duration? get estimatedTimeRemaining {
    if (!_isLoading || _progress <= 0) {
      return null;
    }

    final elapsed = _progressTimer?.tick ?? 0;
    final estimatedTotal = elapsed / _progress;
    final remaining =
        (estimatedTotal - elapsed) * _progressInterval.inMilliseconds;

    return Duration(milliseconds: remaining.toInt());
  }

  /// Reset all internal state
  static void _reset() {
    _progressTimer?.cancel();
    _timeoutTimer?.cancel();
    _progress = 0.0;
    _isLoading = false;
    _isCompleted = false;
    onTimeout = null;
    _progressTimer = null;
    _timeoutTimer = null;
  }

  /// Handle timeout
  static void _handleTimeout() {
    // Stop timers
    _progressTimer?.cancel();
    _timeoutTimer?.cancel();

    // Execute timeout callback if provided
    try {
      onTimeout?.call();
    } catch (e) {
      debugPrint('ProgressManager: Error in onTimeout callback: $e');
    }

    // Reset state
    _reset();
  }

  /// Configure progress simulation parameters
  static void configure({
    Duration? progressInterval,
    double? progressIncrement,
    double? maxSimulatedProgress,
  }) {
    if (progressInterval != null) {
      _progressInterval = progressInterval;
    }
    if (progressIncrement != null) {
      _progressIncrement = progressIncrement.clamp(0.001, 0.1);
    }
    if (maxSimulatedProgress != null) {
      _maxSimulatedProgress = maxSimulatedProgress.clamp(0.1, 0.99);
    }
  }
}
