import 'package:flutter/foundation.dart';

/// 章节。正文为占位文本，接接口时替换 [paragraphs]。
@immutable
class Chapter {
  const Chapter({
    required this.title,
    required this.paragraphs,
    this.totalPages = 208,
  });

  final String title;
  /// 每段为一行，渲染时空一行
  final List<String> paragraphs;
  final int totalPages;

  /// 竖排引擎需要的纯文本视图：段落间用换行分隔，标点禁则在此层处理。
  String get plainText => paragraphs.join('\n');
}
