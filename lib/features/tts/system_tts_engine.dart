/// 系统 TTS 实现：包装 flutter_tts，按句合成、广播字符区间给阅读页做跟读高亮。
library;

import 'dart:async';

import 'package:flutter_tts/flutter_tts.dart';
import 'package:yuedu/features/tts/tts_engine.dart';

final class SystemTtsEngine implements TtsEngine {
  SystemTtsEngine({FlutterTts? tts}) : _tts = tts ?? FlutterTts();

  final FlutterTts _tts;
  final _stateCtrl = StreamController<TtsEngineState>.broadcast();
  final _utteranceCtrl = StreamController<TtsUtterance>.broadcast();

  bool _ready = false;
  bool _disposed = false;
  bool _cancelled = false;

  @override
  Stream<TtsEngineState> get state => _stateCtrl.stream;

  @override
  Future<void> init() async {
    if (_ready || _disposed) return;
    _emit(TtsEngineState.initializing);
    try {
      await _tts.setLanguage('zh-CN');
      await _tts.setSpeechRate(0.5);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
      _ready = true;
      _emit(TtsEngineState.ready);
    } catch (_) {
      _emit(TtsEngineState.error);
    }
  }

  @override
  Stream<TtsUtterance> speak(String text, {double rate = 1.0}) {
    if (_disposed) return const Stream.empty();

    // 取消上一轮；用标志位而不是 Completer.complete()，避免重复 complete 抛异常
    _cancelled = true;
    final sentences = splitSentences(text);
    if (sentences.isEmpty) {
      _emit(TtsEngineState.ready);
      return const Stream.empty();
    }

    // flutter_tts 的 rate 范围约 0.0~1.0，把 0.8~2.0× 映射进去
    final ttsRate =
        (0.3 + 0.45 * rate.clamp(0.8, 2.0) / 2.0).clamp(0.1, 1.0);

    unawaited(_run(sentences, ttsRate));
    return _utteranceCtrl.stream;
  }

  Future<void> _run(
    List<(String, int, int)> sentences,
    double ttsRate,
  ) async {
    _cancelled = false;
    try {
      await init();
      await _tts.setSpeechRate(ttsRate);
      _emit(TtsEngineState.speaking);

      for (var i = 0; i < sentences.length; i++) {
        if (_cancelled || _disposed) break;
        final (seg, start, end) = sentences[i];
        final speech = normalizeForSpeech(seg);
        if (speech.isEmpty) continue;

        _utteranceCtrl.add(TtsUtterance(
          text: speech,
          charStart: start,
          charEnd: end,
          isFinal: i == sentences.length - 1,
        ));
        await _speakOne(speech);
      }

      if (!_cancelled && !_disposed) {
        _emit(TtsEngineState.ready);
      }
    } catch (_) {
      _emit(TtsEngineState.error);
    }
  }

  /// 等一句真正播完再进下一句，否则高亮会跑在声音前面。
  /// 用 setCompletionHandler 而不是 awaitSpeakCompletion，兼容 4.x 各种版本。
  Future<void> _speakOne(String speech) async {
    final done = Completer<void>();
    void finish() {
      if (!done.isCompleted) done.complete();
    }

    _tts.setCompletionHandler(finish);
    _tts.setErrorHandler((_) => finish());
    await _tts.speak(speech);
    await done.future.timeout(
      const Duration(seconds: 60),
      onTimeout: () {},
    );
  }

  @override
  Future<void> pause() async {
    _cancelled = true;
    try {
      await _tts.stop();
    } catch (_) {}
    _emit(TtsEngineState.paused);
  }

  @override
  Future<void> stop() async {
    _cancelled = true;
    try {
      await _tts.stop();
    } catch (_) {}
    if (!_utteranceCtrl.isClosed) {
      _utteranceCtrl.add(
        const TtsUtterance(text: '', charStart: -1, charEnd: -1),
      );
    }
    _emit(TtsEngineState.ready);
  }

  @override
  Future<void> shutdown() async {
    _disposed = true;
    _cancelled = true;
    try {
      await _tts.stop();
    } catch (_) {}
    await _stateCtrl.close();
    await _utteranceCtrl.close();
  }

  void _emit(TtsEngineState s) {
    if (!_stateCtrl.isClosed) _stateCtrl.add(s);
  }
}
