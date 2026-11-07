/// 竖排阅读页的高亮几何：把听书引擎回灌的字符区间，换算成「某一页里
/// 需要涂蓝的竖列索引集合」。
///
/// 关键：必须用阅读页真实的 [VerticalLayout] 来分页，不能自己另建一套参数，
/// 否则列宽/列容对不上，高亮会漂。
library;

import 'package:yuedu/features/reading/vertical_reader.dart';

Set<int> columnsForPageRange({
  required String text,
  required int start,
  required int end,
  required VerticalLayout layout,
  required int pageIndex,
}) {
  if (end <= start || text.isEmpty) return const <int>{};
  final pages = paginateVertical(text: text, layout: layout);
  if (pageIndex < 0 || pageIndex >= pages.length) return const <int>{};

  // 前面各页累计了多少个「已排入」的字符
  int acc = 0;
  for (int pi = 0; pi < pageIndex; pi++) {
    for (final col in pages[pi].columns) {
      acc += col.chars.length;
    }
  }

  final Set<int> cols = <int>{};
  final VerticalPage page = pages[pageIndex];
  for (int ci = 0; ci < page.columns.length; ci++) {
    final int len = page.columns[ci].chars.length;
    if (acc < end && acc + len > start) {
      cols.add(ci);
    }
    acc += len;
  }
  return cols;
}
