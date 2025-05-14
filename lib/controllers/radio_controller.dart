// import 'dart:async';
// import 'dart:math';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:just_audio/just_audio.dart';
// import 'package:audio_session/audio_session.dart';
// import 'package:permission_handler/permission_handler.dart';
//
// class RadioController extends GetxController {
//   final AudioPlayer _player = AudioPlayer();
//   var isPlaying = false.obs;
//   var bars = List<double>.filled(30, 0.0).obs;
//   static const platform = MethodChannel('visualizer');
//   Timer? _timer;
//   bool _visualizerInitialized = false;
//
//   void debugPrintBars() {
//     ever(bars, (value) => debugPrint('Bars updated: $value'));
//   }
//
//   @override
//   void onInit() {
//     super.onInit();
//     debugPrintBars();
//     initAudioSession();
//   }
//
//   Future<void> initAudioSession() async {
//     final session = await AudioSession.instance;
//     await session.configure(const AudioSessionConfiguration.music());
//     _player.playbackEventStream.listen(_handlePlaybackEvent);
//   }
//
//   Future<bool> requestAudioPermission() async {
//     final status = await Permission.microphone.request();
//     return status.isGranted;
//   }
//
//   void _handlePlaybackEvent(PlaybackEvent event) {
//     isPlaying.value = _player.playing;
//     if (_player.playing && !_visualizerInitialized) {
//       _startVisualizer();
//     } else if (!_player.playing) {
//       _stopVisualizer();
//     }
//   }
//
//   Future<void> togglePlayPause(String url) async {
//     try {
//       if (isPlaying.value) {
//         await pauseRadio();
//       } else {
//         await playRadio(url);
//       }
//     } catch (e) {
//       Get.snackbar('Error', 'Failed to toggle play/pause: $e');
//     }
//   }
//
//   Future<void> playRadio(String url) async {
//     try {
//       final hasPermission = await requestAudioPermission();
//       if (!hasPermission) {
//         throw Exception('Microphone permission denied');
//       }
//
//       await _player.setUrl(url);
//       await _player.play();
//     } catch (e) {
//       Get.snackbar('Error', 'Failed to play radio: $e');
//     }
//   }
//
//   Future<void> pauseRadio() async {
//     try {
//       await _player.pause();
//     } catch (e) {
//       Get.snackbar('Error', 'Failed to pause radio: $e');
//       rethrow;
//     }
//   }
//
//   Future<void> _startVisualizer() async {
//     if (_visualizerInitialized) {
//       debugPrint('Visualizer already initialized, skipping...');
//       return;
//     }
//
//     _timer?.cancel();
//     debugPrint('Starting visualizer...');
//     try {
//       int? audioSessionId = await _player.androidAudioSessionId;
//       await platform.invokeMethod('initVisualizer', {'audioSessionId': audioSessionId});
//       debugPrint('Visualizer initialized with audioSessionId: $audioSessionId');
//       _visualizerInitialized = true;
//
//       _timer = Timer.periodic(const Duration(milliseconds: 200), (timer) async {
//         if (!isPlaying.value) {
//           debugPrint('Stopping visualizer due to pause');
//           timer.cancel();
//           return;
//         }
//         try {
//           final waveform = await platform.invokeMethod('getWaveform');
//           if (waveform == null || waveform is! List) {
//             debugPrint('Invalid waveform data received');
//             bars.value = List.filled(30, 0.0);
//             return;
//           }
//           debugPrint('Waveform received: ${waveform.length} samples');
//           final List<int> data = List<int>.from(waveform);
//           bars.value = _processWaveform(data);
//         } catch (e) {
//           debugPrint('Error getting waveform: $e');
//           bars.value = List.filled(30, 0.0);
//         }
//       });
//     } catch (e) {
//       debugPrint('Error initializing visualizer: $e');
//       _visualizerInitialized = false;
//     }
//   }
//
//   List<double> _processWaveform(List<int> waveform) {
//     // Check for invalid waveform data (all -128, 128, or 0)
//     if (waveform.isEmpty ||
//         waveform.every((val) => val == 0) ||
//         waveform.every((val) => val == 128) ||
//         waveform.every((val) => val == -128)) {
//       debugPrint('Invalid waveform data detected: all values are uniform');
//       return List.filled(30, 0.0);
//     }
//
//     int samplesPerBar = (waveform.length / 30).round();
//     List<double> result = List.filled(30, 0.0);
//
//     // Calculate maximum absolute value
//     int globalMax = waveform.fold(
//       0,
//           (max, value) => value.abs() > max ? value.abs() : max,
//     );
//     globalMax = globalMax > 0 ? globalMax : 1;
//
//     for (int i = 0; i < 30; i++) {
//       int start = i * samplesPerBar;
//       int end = (i + 1) * samplesPerBar;
//       end = end.clamp(0, waveform.length);
//
//       double sum = 0;
//       int count = 0;
//
//       for (int j = start; j < end; j++) {
//         sum += waveform[j].abs() / globalMax;
//         count++;
//       }
//
//       result[i] = count > 0 ? (sum / count) : 0.0;
//     }
//
//     // Apply smoother amplification
//     result = result.map((val) => pow(val, 2.0).toDouble().clamp(0.0, 1.0)).toList();
//
//     return result;
//   }
//
//   void _stopVisualizer() {
//     _timer?.cancel();
//     _visualizerInitialized = false;
//     bars.value = List.filled(30, 0.0);
//     try {
//       platform.invokeMethod('stopVisualizer');
//     } catch (e) {
//       debugPrint('Error stopping visualizer: $e');
//     }
//   }
//
//   @override
//   void onClose() {
//     _timer?.cancel();
//     _player.dispose();
//     try {
//       platform.invokeMethod('releaseVisualizer');
//     } catch (e) {
//       debugPrint('Error releasing visualizer: $e');
//     }
//     super.onClose();
//   }
// }


import 'dart:async';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';

class RadioController extends GetxController {
  final AudioPlayer _player = AudioPlayer();
  var isPlaying = false.obs;
  var bars = List<double>.filled(30, 0.0).obs;
  static const platform = MethodChannel('visualizer');
  Timer? _timer;
  bool _visualizerInitialized = false;

  void debugPrintBars() {
    ever(bars, (value) => debugPrint('Bars updated: $value'));
  }

  @override
  void onInit() {
    super.onInit();
    debugPrintBars();
    initAudioSession();
  }

  Future<void> initAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
    _player.playbackEventStream.listen(_handlePlaybackEvent);
  }

  Future<bool> requestAudioPermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  void _handlePlaybackEvent(PlaybackEvent event) {
    isPlaying.value = _player.playing;
    if (_player.playing && !_visualizerInitialized) {
      _startVisualizer();
    } else if (!_player.playing) {
      _stopVisualizer();
    }
  }

  Future<void> togglePlayPause(String url) async {
    try {
      if (isPlaying.value) {
        await pauseRadio();
      } else {
        await playRadio(url);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to toggle play/pause: $e');
    }
  }

  Future<void> playRadio(String url) async {
    try {
      final hasPermission = await requestAudioPermission();
      if (!hasPermission) {
        throw Exception('Microphone permission denied');
      }

      await _player.setUrl(url);
      await _player.play();
    } catch (e) {
      Get.snackbar('Error', 'Failed to play radio: $e');
    }
  }

  Future<void> pauseRadio() async {
    try {
      await _player.pause();
    } catch (e) {
      Get.snackbar('Error', 'Failed to pause radio: $e');
      rethrow;
    }
  }

  Future<void> _startVisualizer() async {
    if (_visualizerInitialized) {
      debugPrint('Visualizer already initialized, skipping...');
      return;
    }

    _timer?.cancel();
    debugPrint('Starting visualizer...');
    try {
      int? audioSessionId = await _player.androidAudioSessionId;
      await platform.invokeMethod('initVisualizer', {'audioSessionId': audioSessionId});
      debugPrint('Visualizer initialized with audioSessionId: $audioSessionId');
      _visualizerInitialized = true;

      // تأخیر 500 میلی‌ثانیه برای اطمینان از آماده بودن پخش
      await Future.delayed(const Duration(milliseconds: 500));

      _timer = Timer.periodic(const Duration(milliseconds: 200), (timer) async {
        if (!isPlaying.value) {
          debugPrint('Stopping visualizer due to pause');
          timer.cancel();
          return;
        }
        try {
          final waveform = await platform.invokeMethod('getWaveform');
          if (waveform == null || waveform is! List) {
            debugPrint('Invalid waveform data received');
            bars.value = List.filled(30, 0.0);
            return;
          }
          debugPrint('Waveform received: ${waveform.length} samples');
          final List<int> data = List<int>.from(waveform);
          final processedBars = await compute(_processWaveform, data);
          bars.value = processedBars;
        } catch (e) {
          debugPrint('Error getting waveform: $e');
          bars.value = List.filled(30, 0.0);
        }
      });
    } catch (e) {
      debugPrint('Error initializing visualizer: $e');
      _visualizerInitialized = false;
    }
  }

  static List<double> _processWaveform(List<int> waveform) {
    // Check for invalid waveform data (all -128, 128, or 0)
    if (waveform.isEmpty ||
        waveform.every((val) => val == 0) ||
        waveform.every((val) => val == 128) ||
        waveform.every((val) => val == -128)) {
      debugPrint('Invalid waveform data detected: all values are uniform');
      return List.filled(30, 0.0);
    }

    int samplesPerBar = (waveform.length / 30).round();
    List<double> result = List.filled(30, 0.0);

    // Calculate maximum absolute value
    int globalMax = waveform.fold(
      0,
          (max, value) => value.abs() > max ? value.abs() : max,
    );
    globalMax = globalMax > 0 ? globalMax : 1;

    for (int i = 0; i < 30; i++) {
      int start = i * samplesPerBar;
      int end = (i + 1) * samplesPerBar;
      end = end.clamp(0, waveform.length);

      double sum = 0;
      int count = 0;

      for (int j = start; j < end; j++) {
        sum += waveform[j].abs() / globalMax;
        count++;
      }

      result[i] = count > 0 ? (sum / count) : 0.0;
    }

    // Apply smoother amplification
    result = result.map((val) => pow(val, 2.0).toDouble().clamp(0.0, 1.0)).toList();

    return result;
  }

  void _stopVisualizer() {
    _timer?.cancel();
    _visualizerInitialized = false;
    bars.value = List.filled(30, 0.0);
    try {
      platform.invokeMethod('stopVisualizer');
    } catch (e) {
      debugPrint('Error stopping visualizer: $e');
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    _player.dispose();
    try {
      platform.invokeMethod('releaseVisualizer');
    } catch (e) {
      debugPrint('Error releasing visualizer: $e');
    }
    super.onClose();
  }
}