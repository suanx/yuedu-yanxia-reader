/// 系统 TTS 实现：通过 MethodChannel 调用 Android 原生
/// [android.speech.tts.TextToSpeech]，按句朗读并广播字符区间给阅读页做跟读高亮。
///
/// 之所以不用 flutter_tts 插件：该插件较新版本会把 Kotlin 2.2 的 stdlib
/// 拖进 Gradle 依赖，和 Flutter 3.24 自带的 Kotlin 1.8 编译器不兼容，
/// CI 上 :flutter_tts:compileReleaseKotlin 必挂。原生通道只用平台自带
/// 能力，零第三方 Kotlin 依赖，构建最稳。
library;

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:yuedu/features/tts/tts_engine.dart';

final class SystemTtsEngine implements TtsEngine {
  static const MethodChannel _channel = MethodChannel('yanxia/tts');

  SystemTtsEngine() {
    _channel.setMethodCallHandler(_onNativeEvent);
  }

  final StreamController<TtsEngineState> _stateCtrl =
      StreamController<TtsEngineState>.broadcast();
  final StreamController<TtsUtterance> _utteranceCtrl =
      StreamController<TtsUtterance>.broadcast();

  bool _ready = false;
  bool _disposed = false;
  bool _cancelled = false;
  double _currentRate = 0.5;

  /// 当前句的「播完」信号，由原生侧 onDone / onError 回调触发。
  Completer<void>? _sentenceDone;

  @override
  Stream<TtsEngineState> get state => _stateCtrl.stream;

  Future<void> _onNativeEvent(MethodCall call) async {
    if (call.method == 'onDone' || call.method == 'onError') {
      final done = _sentenceDone;
      _sentenceDone = null;
      if (done != null && !done.isCompleted) done.complete();
    }
  }

  @override
  Future<void> init() async {
    if (_ready || _disposed) return;
    _emit(TtsEngineState.initializing);
    try {
      final ok =
          await _channel.invokeMethod<bool>('init') ?? false;
      _ready = ok;
      _emit(ok ? TtsEngineState.ready : TtsEngineState.error);
    } catch (_) {
      _emit(TtsEngineState.error);
    }
  }

  @override
  Stream<TtsUtterance> speak(String text, {double rate = 1.0}) {
    if (_disposed) return const Stream.empty();

    _cancelled = true; // 取消上一轮
    final sentences = splitSentences(text);
    if (sentences.isEmpty) {
      _emit(TtsEngineState.ready);
      return const Stream.empty();
    }

    _currentRate =
        (0.3 + 0.45 * rate.clamp(0.8, 2.0) / 2.0).clamp(0.1, 1.0);
    unawaited(_run(sentences));
    return _utteranceCtrl.stream;
  }

  Future<void> _run(List<(String, int, int)> sentences) async {
    _cancelled = false;
    try {
      await init();
      if (!_ready) {
        _emit(TtsEngineState.error);
        return;
      }
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

  /// 等原生把这一句真正念完再进下一句，否则高亮会跑在声音前面。
  Future<void> _speakOne(String speech) async {
    final done = Completer<void>();
    _sentenceDone = done;
    try {
      final ok = await _channel.invokeMethod<bool>('speak', <String, dynamic>{
        'text': speech,
        'rate': _currentRate,
      });
      if (ok != true && !done.isCompleted) done.complete();
    } catch (_) {
      if (!done.isCompleted) done.complete();
    }
    await done.future.timeout(
      const Duration(seconds: 60),
      onTimeout: () {},
    );
    if (_sentenceDone == done) _sentenceDone = null;
  }

  void _finishCurrentSentence() {
    final done = _sentenceDone;
    _sentenceDone = null;
    if (done != null && !done.isCompleted) done.complete();
  }

  @override
  Future<void> pause() async {
    _cancelled = true;
    _finishCurrentSentence();
    try {
      await _channel.invokeMethod<void>('stop');
    } catch (_) {}
    _emit(TtsEngineState.paused);
  }

  @override
  Future<void> stop() async {
    _cancelled = true;
    _finishCurrentSentence();
    try {
      await _channel.invokeMethod<void>('stop');
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
    _finishCurrentSentence();
    try {
      await _channel.invokeMethod<void>('shutdown');
      await _channel.setMethodCallHandler(null);
    } catch (_) {}
    await _stateCtrl.close();
    await _utteranceCtrl.close();
  }

  void _emit(TtsEngineState s) {
    if (!_stateCtrl.isClosed) _stateCtrl.add(s);
  }
}
