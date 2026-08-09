import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../common/result.dart';

class SpeechRecognitionService {
  final stt.SpeechToText _speech = stt.SpeechToText();

  bool _isInitialized = false;

  bool get isListening => _speech.isListening;

  Future<Result<void>> checkPermission() async {
    final microphoneStatus = await Permission.microphone.request();
    if (microphoneStatus.isDenied || microphoneStatus.isPermanentlyDenied) {
      return Result.failure(error: 'Quyền truy cập micro chưa được cấp');
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final speechStatus = await Permission.speech.request();
      if (speechStatus.isDenied || speechStatus.isPermanentlyDenied) {
        return Result.failure(error: 'Quyền nhận diện giọng nói chưa được cấp');
      }
    }

    return Result.success(data: null);
  }

  Future<bool> initialize({void Function(String message)? onError}) async {
    if (_isInitialized) return true;

    _isInitialized = await _speech.initialize(
      onError: (error) => onError?.call(error.errorMsg),
    );

    return _isInitialized;
  }

  Future<void> startListening({
    required void Function(String text) onResult,
    void Function(String text)? onPartialResult,
  }) async {
    await _speech.listen(
      onResult: (result) {
        if (result.finalResult) {
          onResult(result.recognizedWords);
        } else {
          onPartialResult?.call(result.recognizedWords);
        }
      },
      listenOptions: stt.SpeechListenOptions(
        localeId: 'vi_VN',
        partialResults: true,
        cancelOnError: true,
        listenMode: stt.ListenMode.dictation,
      ),
    );
  }

  Future<void> stopListening() async {
    await _speech.stop();
  }
}
