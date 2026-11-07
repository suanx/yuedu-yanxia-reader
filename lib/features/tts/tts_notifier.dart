/// 听书状态容器：持有引擎单例 + 播放态 + 当前高亮区间，UI 订阅它即可刷新。
library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yuedu/features/tts/system_tts_engine.dart';
import 'package:yuedu/features/tts/tts_engine.dart';

final ttsEngineProvider = Provider<TtsEngine>((ref) {
  final engine = SystemTtsEngine();
  ref.onDispose(engine.shutdown);
  return engine;
});

final ttsStateProvider = StreamProvider<TtsEngineState>((ref) {
  return ref.watch(ttsEngineProvider).state;
});

/// 当前正在朗读的字符区间（高亮用）；(-1, -1) 表示无高亮。
final ttsHighlightProvider = StateProvider<(int, int)>((ref) => (-1, -1));

final ttsRateProvider = StateProvider<double>((ref) => 1.0);

final ttsControllerProvider = Provider<TtsController>((ref) {
  return TtsController(ref);
});

final class TtsController {
  TtsController(this._ref);

  final Ref _ref;
  StreamSubscription<TtsUtterance>? _sub;

  TtsEngine get _engine => _ref.read(ttsEngineProvider);
  double get rate => _ref.read(ttsRateProvider);

  static const rates = <double>[0.8, 1.0, 1.25, 1.5, 2.0];

  /// 开始朗读 [text]。重复调用会先取消上一次订阅。
  void play(String text) {
    _sub?.cancel();
    _sub = _engine.speak(text, rate: rate).listen((u) {
      final notifier = _ref.read(ttsHighlightProvider.notifier);
      notifier.state =
          u.charStart < 0 ? (-1, -1) : (u.charStart, u.charEnd);
    });
    _ref.onDispose(() => _sub?.cancel());
  }

  Future<void> pause() => _engine.pause();

  Future<void> stop() async {
    await _engine.stop();
    _ref.read(ttsHighlightProvider.notifier).state = (-1, -1);
  }

  void cycleRate() {
    final i = rates.indexOf(rate);
    _ref.read(ttsRateProvider.notifier).state =
        rates[(i + 1) % rates.length];
  }

  String get rateLabel => rate == 1.0 ? '1×' : '${rate.toStringAsFixed(2)}×';
}
