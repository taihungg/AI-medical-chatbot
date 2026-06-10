import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Thin wrapper around [SpeechToText] for tap-to-toggle voice input.
class VoiceInputService {
  VoiceInputService({SpeechToText? speech})
      : _speech = speech ?? SpeechToText();

  final SpeechToText _speech;
  bool _initialized = false;
  bool _listening = false;
  String _transcript = '';
  String? _lastErrorMessage;
  Completer<void>? _sessionEndCompleter;

  void Function(String)? onPartialResult;
  void Function(bool isListening)? onListeningStateChanged;

  bool get isAvailable => _initialized && _speech.isAvailable;
  bool get isListening => _listening;
  String? get lastErrorMessage => _lastErrorMessage;

  Future<bool> initialize() async {
    _lastErrorMessage = null;
    _initialized = await _speech.initialize(
      onError: (error) {
        _lastErrorMessage = error.errorMsg;
        _setListening(false);
      },
      onStatus: _onEngineStatus,
    );
    return isAvailable;
  }

  void _onEngineStatus(String status) {
    if (status == 'listening') {
      _setListening(true);
    } else if (status == 'done' ||
        status == 'notListening' ||
        status == 'doneNoResult') {
      _setListening(false);
      _completeSessionEnd();
    }
  }

  void _setListening(bool value) {
    if (_listening == value) return;
    _listening = value;
    onListeningStateChanged?.call(value);
  }

  void _completeSessionEnd() {
    if (_sessionEndCompleter != null && !_sessionEndCompleter!.isCompleted) {
      _sessionEndCompleter!.complete();
    }
    _sessionEndCompleter = null;
  }

  /// Ends any active session and waits until the engine is idle (needed on web).
  Future<void> _prepareForNewSession() async {
    if (_speech.isListening || _listening) {
      _sessionEndCompleter = Completer<void>();
      try {
        await _speech.stop();
      } catch (_) {
        await _speech.cancel();
      }
      _setListening(false);

      try {
        await _sessionEndCompleter!.future.timeout(
          const Duration(seconds: 2),
          onTimeout: () {},
        );
      } catch (_) {}

      _completeSessionEnd();
    }

    // Chrome needs cancel + pause between sessions even when flags look idle.
    if (kIsWeb) {
      try {
        await _speech.cancel();
      } catch (_) {}
      await Future<void>.delayed(const Duration(milliseconds: 250));
    }
  }

  Future<bool> startListening({String localeId = 'vi_VN'}) async {
    if (!isAvailable) return false;

    _lastErrorMessage = null;
    await _prepareForNewSession();

    final resolvedLocale = _formatLocale(await _resolveLocale(localeId));
    _transcript = '';

    try {
      await _speech.listen(
        onResult: _onResult,
        listenOptions: SpeechListenOptions(
          localeId: resolvedLocale,
          listenMode: ListenMode.dictation,
          listenFor: const Duration(seconds: 60),
          pauseFor: const Duration(seconds: 10),
          cancelOnError: false,
          partialResults: true,
        ),
      );
    } on ListenFailedException catch (e) {
      _setListening(false);
      _lastErrorMessage = e.message ?? 'Không thể bắt đầu nghe.';
      return false;
    }

    // Engine reports listening via onStatus; brief wait for web onstart.
    if (!_listening) {
      await Future<void>.delayed(const Duration(milliseconds: 200));
    }

    if (!_listening && !_speech.isListening) {
      _lastErrorMessage ??=
          _speech.lastError?.errorMsg ?? 'Không thể bắt đầu nghe.';
      return false;
    }

    _setListening(true);
    return true;
  }

  Future<String?> stopListening() async {
    final text = _transcript.trim();

    if (_speech.isListening || _listening) {
      await _prepareForNewSession();
    } else {
      _setListening(false);
    }

    _transcript = '';
    return text.isEmpty ? null : text;
  }

  Future<void> cancel() async {
    try {
      await _speech.cancel();
    } catch (_) {}
    _setListening(false);
    _transcript = '';
    _completeSessionEnd();
  }

  void _onResult(SpeechRecognitionResult result) {
    _transcript = result.recognizedWords;
    onPartialResult?.call(_transcript);
  }

  Future<String> _resolveLocale(String preferred) async {
    final locales = await _speech.locales();
    if (locales.isEmpty) return _formatLocale(preferred);

    final normalizedPreferred = preferred.replaceAll('-', '_');
    for (final locale in locales) {
      if (locale.localeId == preferred ||
          locale.localeId == normalizedPreferred) {
        return locale.localeId;
      }
    }
    for (final locale in locales) {
      if (locale.localeId.startsWith('vi')) return locale.localeId;
    }
    return locales.first.localeId;
  }

  /// Web Speech API expects BCP-47 (`vi-VN`); mobile uses `vi_VN`.
  String _formatLocale(String localeId) {
    if (kIsWeb) {
      return localeId.replaceAll('_', '-');
    }
    return localeId.replaceAll('-', '_');
  }
}
