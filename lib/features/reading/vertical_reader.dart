import 'package:flutter/material.dart';

/// 檐下 · 竖排引擎
///
/// Flutter 的 [Text] 不支持真正的竖排，这里自己逐字排版：从右往左成列、
/// 每列从上往下成字，并做中文排版最基本的「避头避尾」。
///
/// 注意：[VerticalColumn] / [VerticalPage] 是公开类型，因为阅读页需要在
/// 另一个库里读取列内容来绘制跟读高亮；私有类型跨库会导致分析器报错。

// ----------------------------- 禁则表 -----------------------------

const Set<String> _cannotLead = {
  '\u3001', '\uff0c', '\u3002', '\uff0e', '\uff1b', '\uff1a', '\uff01',
  '\uff1f', '\u201d', '\u201c', '\uff09', '\uff3d', '\u300b', '\u2018',
  '\u2019', '\u2026', '\u2014', '\uff5e',
};

const Set<String> _cannotTail = {
  '「', '『', '“', "'", '‘', '（', '(', '【', '[', '《', '<',
};

/// 压缩占位符：破折号、省略号在竖排里压成一个字高，避免独占两格。
const Map<String, int> _compress = {
  '——': 1,
  '—': 1,
  '……': 1,
  '…': 1,
  '~~': 1,
  '~': 1,
};

// ----------------------------- 数据模型 -----------------------------

/// 一「列」竖排文字。竖排里列是横向单位，列内字从上往下。
class VerticalColumn {
  VerticalColumn(this.charWidth);

  final double charWidth;
  final List<String> chars = [];

  /// 本列已占用的高度（每个字累加 charHeight），供高亮层算列底
  double height = 0;

  bool get isEmpty => chars.isEmpty;

  void add(String c, double h) {
    chars.add(c);
    height += h;
  }
}

/// 分页结果：每一页 = 若干列。阅读页只管从左往右滑着展示这些列。
class VerticalPage {
  const VerticalPage(this.columns, {required this.isFirst});

  final List<VerticalColumn> columns;
  final bool isFirst;
}

/// 供阅读页构造「空页」，避免跨库引用私有类型。
VerticalPage emptyVerticalPage(VerticalLayout layout) =>
    VerticalPage([VerticalColumn(layout.charWidth)], isFirst: true);

/// 排版参数。抽出来是为了让字号/行距/字距变化时一键重排。
class VerticalLayout {
  const VerticalLayout({
    required this.charHeight,
    required this.charWidth,
    required this.columnGap,
    required this.lineLeading,
    required this.contentTop,
    required this.contentBottom,
    required this.contentRight,
    required this.contentLeft,
  });

  final double charHeight;
  final double charWidth;
  final double columnGap;
  final double lineLeading;
  final double contentTop;
  final double contentBottom;
  final double contentRight;
  final double contentLeft;

  double get usableHeight => contentBottom - contentTop;

  int get columnCapacity =>
      (usableHeight / charHeight).floor().clamp(1, 9999);

  int get columnsFit =>
      ((contentRight - contentLeft - charWidth) / columnGap)
          .floor()
          .clamp(1, 9999);
}

// ----------------------------- 引擎 -----------------------------

/// 把纯文本切成「页」。调用方拿到的就是可渲染的竖排版面。
List<VerticalPage> paginateVertical({
  required String text,
  required VerticalLayout layout,
  int startPage = 0,
}) {
  final chars = _normalize(text);
  final List<VerticalPage> pages = [];
  final int colCap = layout.columnCapacity.toInt();
  if (colCap <= 0) return pages;

  int i = 0;
  bool isFirst = startPage == 0;

  while (i < chars.length) {
    final List<VerticalColumn> columns = [];
    final int colsThisPage = layout.columnsFit.toInt().clamp(1, 9999);
    int filledCols = 0;

    while (filledCols < colsThisPage && i < chars.length) {
      final VerticalColumn col = VerticalColumn(layout.charWidth);
      int rows = 0;

      while (rows < colCap && i < chars.length) {
        final String c = chars[i];

        // 段落换行：结束当前列
        if (c == '\n') {
          i++;
          break;
        }

        // 禁则：闭音标点不落列顶，黏到上一列末尾
        if (_cannotLead.contains(c) && col.chars.isNotEmpty) {
          break;
        }

        final int span = _compress[c] ?? 1;
        col.add(c, layout.charHeight);
        i++;
        rows += span;

        // 段末句号后强制换列，让竖排有「提行」呼吸
        if (c == '。' || c == '！' || c == '？' || c == '…') {
          if (i < chars.length && !_cannotLead.contains(chars[i])) {
            break;
          }
        }
      }

      if (col.isEmpty) break;
      columns.add(col);
      filledCols++;

      if (i < chars.length && chars[i] == '\n') {
        i++;
      }
    }

    if (columns.isEmpty) break;
    pages.add(VerticalPage(columns, isFirst: isFirst));
    isFirst = false;
  }

  return pages;
}

/// 归一化：统一换行、压掉多余空白，空格转成全角空格便于竖排留白。
/// 用 runes 遍历而不是 t[k]（Dart 的 String 没有下标操作符）。
List<String> _normalize(String text) {
  final String t = text
      .replaceAll('\r\n', '\n')
      .replaceAll('\u3000', '  ')
      .replaceAll(RegExp(r'[ \t]+'), ' ');
  final List<String> out = [];
  for (final rune in t.runes) {
    final String ch = String.fromCharCode(rune);
    if (ch == ' ' || ch == '\t') {
      out.add('\u3000');
    } else if (ch == '\n') {
      out.add('\n');
    } else {
      out.add(ch);
    }
  }
  return out;
}

// ----------------------------- 渲染 Widget -----------------------------

/// 竖排页面。最右列为第一列，向左推进 —— 和纸质竖排书翻页方向一致。
class VerticalPageView extends StatelessWidget {
  const VerticalPageView({
    super.key,
    required this.page,
    required this.textStyle,
    required this.charWidth,
    required this.charHeight,
    required this.columnGap,
    required this.contentTop,
    required this.contentRight,
  });

  final VerticalPage page;
  final TextStyle textStyle;
  final double charWidth;
  final double charHeight;
  final double columnGap;
  final double contentTop;
  final double contentRight;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final List<Widget> columns = [];
        double cursorX = contentRight - charWidth;

        for (final col in page.columns) {
          columns.add(
            Positioned(
              right: constraints.maxWidth - cursorX - charWidth,
              top: contentTop,
              width: charWidth,
              height: constraints.maxHeight - contentTop,
              child: _VerticalColumnWidget(
                chars: col.chars,
                textStyle: textStyle,
                charHeight: charHeight,
              ),
            ),
          );
          cursorX -= columnGap;
        }

        return Stack(children: columns);
      },
    );
  }
}

class _VerticalColumnWidget extends StatelessWidget {
  const _VerticalColumnWidget({
    required this.chars,
    required this.textStyle,
    required this.charHeight,
  });

  final List<String> chars;
  final TextStyle textStyle;
  final double charHeight;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: chars.map((c) {
        if (c == '\n' || c == '\u3000') {
          return SizedBox(height: charHeight);
        }
        return SizedBox(
          height: charHeight,
          child: Center(
            child: Text(
              c,
              style: textStyle,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.clip,
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// 便捷入口：给定章节正文，返回可直接放进 PageView 的竖排页列表。
List<Widget> buildVerticalPages({
  required String text,
  required TextStyle textStyle,
  required double fontSize,
  required double lineHeight,
  required double columnGap,
  required double contentTop,
  required double contentBottom,
  required double contentRight,
  required double contentLeft,
  required Color paper,
}) {
  final layout = VerticalLayout(
    charHeight: fontSize * lineHeight,
    charWidth: fontSize * 1.02,
    columnGap: columnGap,
    lineLeading: fontSize * (lineHeight - 1),
    contentTop: contentTop,
    contentBottom: contentBottom,
    contentRight: contentRight,
    contentLeft: contentLeft,
  );

  final pages = paginateVertical(text: text, layout: layout);

  return pages
      .map((p) => RepaintBoundary(
            child: VerticalPageView(
              page: p,
              textStyle: textStyle,
              charWidth: layout.charWidth,
              charHeight: layout.charHeight,
              columnGap: layout.columnGap,
              contentTop: layout.contentTop,
              contentRight: layout.contentRight,
            ),
          ))
      .toList();
}

/// 估算某段文本的竖排「字数进度」。
double verticalProgress(int charIndex, String text) {
  if (text.isEmpty) return 0;
  return (charIndex.clamp(0, text.length)) / text.length;
}

/// 把 [charIndex] 换算成「第几页」，用于从书架恢复阅读位置时定位。
int charIndexToVerticalPage({
  required int charIndex,
  required String text,
  required VerticalLayout layout,
}) {
  final pages = paginateVertical(text: text, layout: layout);
  int acc = 0;
  for (int pi = 0; pi < pages.length; pi++) {
    final int charsInPage =
        pages[pi].columns.fold(0, (s, c) => s + c.chars.length);
    if (charIndex < acc + charsInPage) return pi;
    acc += charsInPage;
  }
  return pages.isEmpty ? 0 : pages.length - 1;
}
