/// 听书引擎抽象层。
///
/// UI 只依赖这一层：横排页、竖排页都不关心语音从哪来。
/// 系统 TTS 离线即用；后续接 Sherpa-ONNX / 云 TTS 时，只新增一个实现类，
/// 把 [ttsEngineProvider] 换掉即可，界面零改动。
///
/// 注意：枚举特意叫 [TtsEngineState] 而不是 TtsState，因为 flutter_tts
/// 自己也导出了一个 TtsState，同名会在实现类里产生歧义。
library;

import 'dart:async';

/// 一句正在（或即将）被朗读的文本片段，附带字符区间供阅读页高亮。
final class TtsUtterance {
  const TtsUtterance({
    required this.text,
    required this.charStart,
    required this.charEnd,
    this.isFinal = true,
  });

  /// 本句文本（已做数字/日期规一化后的朗读稿）
  final String text;

  /// 在原始正文中的起止偏移（含头不含尾），高亮用
  final int charStart;
  final int charEnd;

  /// 是否为该次 speak 的最后一句
  final bool isFinal;
}

enum TtsEngineState { idle, initializing, ready, speaking, paused, error }

/// 把正文切成「朗读句」的朴素规则：句号 / 问号 / 叹号 / 换行 断句。
List<(String, int, int)> splitSentences(String text) {
  if (text.isEmpty) return const [];
  final List<(String, int, int)> out = [];
  final re = RegExp(r'[。！？\n]+');
  int start = 0;
  for (final m in re.allMatches(text)) {
    final seg = text.substring(start, m.start).trim();
    if (seg.isNotEmpty) out.add((seg, start, m.start));
    start = m.end;
  }
  if (start < text.length) {
    final seg = text.substring(start).trim();
    if (seg.isNotEmpty) out.add((seg, start, text.length));
  }
  return out;
}

/// 中文数字 / 日期规一化：把「2026年」读成「二零二六年」，听感更自然。
String normalizeForSpeech(String s) {
  const digits = <String, String>{
    '0': '零',
    '1': '一',
    '2': '二',
    '3': '三',
    '4': '四',
    '5': '五',
    '6': '六',
    '7': '七',
    '8': '八',
    '9': '九',
  };
  s = s.replaceAllMapped(RegExp(r'(\d{4})年'), (m) {
    final b = StringBuffer();
    for (final c in m.group(1)!.runes) {
      b.write(digits[String.fromCharCode(c)] ?? '');
    }
    return '$b年';
  });
  s = s.replaceAllMapped(RegExp(r'\d'), (m) => digits[m.group(0)!] ?? m.group(0)!);
  return s.replaceAll('%', '百分之').replaceAll('℃', '摄氏度');
}

/// 听书引擎契约。
abstract interface class TtsEngine {
  Stream<TtsEngineState> get state;

  /// 初始化（加载语音引擎 / 模型）。可重复调用，第二次应是 no-op。
  Future<void> init();

  /// 逐句产出 [TtsUtterance]，调用方按序播放。
  /// 新一次 [speak] 会取消上一次的朗读。
  Stream<TtsUtterance> speak(String text, {double rate = 1.0});

  /// 暂停（系统 TTS 不支持细粒度 seek，这里退化为停止）。
  Future<void> pause();

  /// 彻底停止并清空高亮区间。
  Future<void> stop();

  Future<void> shutdown();
}
