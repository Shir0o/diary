import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../config/app_strings.dart';

/// An abstract service class to interface with speech recognition capabilities.
/// This abstraction enables clean mocking in tests.
abstract class SpeechService {
  /// Whether the microphone is currently active and listening.
  bool get isListening;

  /// Whether the speech service has been successfully initialized and is available.
  bool get isAvailable;

  /// Initializes the speech recognition engine, requesting permissions if needed.
  /// Returns [true] if successfully initialized and available.
  Future<bool> initialize();

  /// Starts a dictation session.
  ///
  /// Calls [onResult] with newly dictated words.
  /// Calls [onError] with any errors encountered.
  /// Calls [onStatusChange] when listening starts or stops.
  /// Optional [onSoundLevelChange] provides voice amplitude decibel data for animations.
  Future<void> startListening({
    required Function(String text) onResult,
    required Function(String error) onError,
    required Function(bool isListening) onStatusChange,
    Function(double soundLevel)? onSoundLevelChange,
  });

  /// Stops the current listening session.
  Future<void> stopListening();
}

/// Production implementation of [SpeechService] using the `speech_to_text` package.
class SpeechToTextService implements SpeechService {
  final stt.SpeechToText _speechToText;
  bool _isAvailable = false;

  // Active session event listeners
  Function(bool isListening)? _activeOnStatusChange;
  Function(String error)? _activeOnError;

  SpeechToTextService({stt.SpeechToText? speechToText})
    : _speechToText = speechToText ?? stt.SpeechToText();

  @override
  bool get isListening => _speechToText.isListening;

  @override
  bool get isAvailable => _isAvailable;

  @override
  Future<bool> initialize() async {
    if (_isAvailable) return true;
    try {
      _isAvailable = await _speechToText.initialize(
        onError: (errorNotification) {
          debugPrint(
            'SpeechToText Error: ${errorNotification.errorMsg} - permanent: ${errorNotification.permanent}',
          );
          _activeOnError?.call(errorNotification.errorMsg);
        },
        onStatus: (status) {
          debugPrint('SpeechToText Status: $status');
          if (status == 'notListening' || status == 'done') {
            _activeOnStatusChange?.call(false);
          } else if (status == 'listening') {
            _activeOnStatusChange?.call(true);
          }
        },
      );
      return _isAvailable;
    } catch (e) {
      debugPrint('Error initializing SpeechToText: $e');
      _isAvailable = false;
      return false;
    }
  }

  @override
  Future<void> startListening({
    required Function(String text) onResult,
    required Function(String error) onError,
    required Function(bool isListening) onStatusChange,
    Function(double soundLevel)? onSoundLevelChange,
  }) async {
    final available = await initialize();
    if (!available) {
      onError(AppStrings.speechNotAvailable);
      return;
    }

    _activeOnStatusChange = onStatusChange;
    _activeOnError = onError;

    try {
      onStatusChange(true);
      await _speechToText.listen(
        onResult: (result) {
          onResult(result.recognizedWords);
          if (result.finalResult) {
            onStatusChange(false);
            _activeOnStatusChange = null;
            _activeOnError = null;
          }
        },
        onSoundLevelChange: onSoundLevelChange,
        listenOptions: stt.SpeechListenOptions(
          listenMode: stt.ListenMode.dictation,
          cancelOnError: true,
        ),
      );
    } catch (e) {
      onStatusChange(false);
      onError(e.toString());
      _activeOnStatusChange = null;
      _activeOnError = null;
    }
  }

  @override
  Future<void> stopListening() async {
    try {
      await _speechToText.stop();
      _activeOnStatusChange?.call(false);
      _activeOnStatusChange = null;
      _activeOnError = null;
    } catch (e) {
      debugPrint('Error stopping SpeechToText: $e');
    }
  }
}
