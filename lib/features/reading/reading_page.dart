import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yuedu/core/constants/app_constants.dart';
import 'package:yuedu/data/models/chapter.dart';
import 'package:yuedu/data/repositories/mock_library.dart';
import 'package:yuedu/data/repositories/reading_state.dart';
import 'package:yuedu/features/reading/vertical_highlight.dart';
import 'package:yuedu/features/reading/vertical_reader.dart';
import 'package:yuedu/features/tts/tts_notifier.dart';
import 'package:yuedu/features/tts/tts_player_bar.dart';
import 'package:yuedu/widgets/reading_progress_bar.dart';

/// 檐下 · 阅读页
///
/// 两种版式共享一套进度/页码状态：
///   · [ReadingMode.vertical] 竖排：从右往左成列，对齐截图里那种竖排纸质书感
///   · [ReadingMode.horizontal] 横排：截图标配的暖黄纸面 + 段落
///
/// 进度 = 当前页 / 总页数（总页数由真实排版结果决定，不再写死 208），
/// 书架点进来时按已读比例定位，翻页时把位置写回书架。

enum ReadingMode { vertical, horizontal }

class ReadingPage extends ConsumerStatefulWidget {
  const ReadingPage({
    super.key,
    this.bookTitle,
    this.bookId,
    this.initialPage,
    this.totalPages = 208,
  });

  final String? bookTitle;
  final String? bookId;
  final int? initialPage;
  final int totalPages;

  @override
  ConsumerState<ReadingPage> createState() => _ReadingPageState();
}

class _ReadingPageState extends ConsumerState<ReadingPage> {
  late PageController _pageController;
  ReadingMode _mode = ReadingMode.horizontal;

  /// 横排分页用的「段落切片」缓存，避免每次 build 重算
  List<List<String>> _hSlices = [];
  int _realTotal = 1;

  @override
  void initState() {
    super.initState();
    final prefs = ref.read(readingPrefsProvider);
    _pageController = PageController(
      initialPage: (widget.initialPage ?? prefs.currentPage).clamp(0, 9999),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// 横排：把章节段落切成「每屏 4 段」的页。
  List<List<String>> _horizontalSlices() {
    if (_hSlices.isNotEmpty) return _hSlices;
    final paras = currentChapter.paragraphs;
    const perPage = 4;
    _hSlices = <List<String>>[];
    for (int i = 0; i < paras.length; i += perPage) {
      _hSlices.add(paras.skip(i).take(perPage).toList());
    }
    if (_hSlices.isEmpty) _hSlices = <List<String>>[<String>[]];
    return _hSlices;
  }

  int get _horizontalTotal => _horizontalSlices().length.clamp(1, 9999);

  void _jumpToRatio(double ratio) {
    final t = ratio.clamp(0.0, 1.0);
    final idx = (t * (_realTotal - 1)).round().clamp(0, _realTotal - 1);
    if (_pageController.hasClients) {
      _pageController.jumpToPage(idx);
    }
    ref.read(readingPrefsProvider.notifier).setPage(idx, total: _realTotal);
    _writeBack(idx);
  }

  void _onPageChanged(int i) {
    ref.read(readingPrefsProvider.notifier).setPage(i, total: _realTotal);
    _writeBack(i);
  }

  void _writeBack(int i) {
    if (widget.bookId == null) return;
    final ratio = _realTotal > 1 ? i / (_realTotal - 1) : 0.0;
    ref
        .read(bookshelfProgressProvider.notifier)
        .updateProgress(widget.bookId!, ratio, _realTotal);
  }

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(readingPrefsProvider);
    final tone = prefs.paperTone;
    final chapter = currentChapter;
    final isV = _mode == ReadingMode.vertical;
    final plainText = chapter.plainText;

    // 竖排总页数由排版器决定；横排由段落切片决定
    _realTotal = isV ? _verticalTotal(context) : _horizontalTotal;
    final page = prefs.currentPage.clamp(0, _realTotal - 1);
    final progress = _realTotal > 1 ? page / (_realTotal - 1) : 0.0;

    return Scaffold(
      backgroundColor: tone.paperColor,
      body: SafeArea(
        child: Column(
          children: [
            _ReadingAppBar(
              bookTitle: widget.bookTitle ?? chapter.title,
              mode: _mode,
              plainText: plainText,
              onToggleMode: () {
                final nextIsV = !isV;
                final nextTotal =
                    nextIsV ? _verticalTotal(context) : _horizontalTotal;
                final target = page.clamp(0, nextTotal - 1);
                setState(() {
                  _mode = nextIsV
                      ? ReadingMode.vertical
                      : ReadingMode.horizontal;
                  _pageController.dispose();
                  _pageController = PageController(initialPage: target);
                });
              },
            ),
            Expanded(
              child: isV
                  ? _VerticalBody(
                      key: const ValueKey('v'),
                      controller: _pageController,
                      onPageChanged: _onPageChanged,
                    )
                  : _HorizontalBody(
                      key: const ValueKey('h'),
                      chapter: chapter,
                      fontSize: prefs.fontSize,
                      ink: tone.inkColor,
                      slices: _horizontalSlices(),
                      controller: _pageController,
                      onPageChanged: _onPageChanged,
                    ),
            ),
            ReadingProgressBar(
              progress: progress,
              page: page + 1,
              total: _realTotal,
              onChanged: _jumpToRatio,
            ),
          ],
        ),
      ),
    );
  }

  int _verticalTotal(BuildContext context) {
    final layout = _vLayout(MediaQuery.sizeOf(context));
    final pages = paginateVertical(text: currentChapter.plainText, layout: layout);
    return pages.length.clamp(1, 99999);
  }
}

/// 竖排正文：右→左翻页，每页由 [_VerticalPageShell] 负责排版与渲染。
class _VerticalBody extends ConsumerWidget {
  const _VerticalBody({
    super.key,
    required this.controller,
    required this.onPageChanged,
  });

  final PageController controller;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(readingPrefsProvider);
    final tone = prefs.paperTone;
    final layout = _vLayout(MediaQuery.sizeOf(context));
    final pages = paginateVertical(
      text: currentChapter.plainText,
      layout: layout,
    );
    final safe = pages.isEmpty ? <VerticalPage>[emptyVerticalPage(layout)] : pages;

    return PageView.builder(
      controller: controller,
      itemCount: safe.length,
      onPageChanged: onPageChanged,
      itemBuilder: (_, i) => _VerticalPageShell(
        page: safe[i],
        pageIndex: i,
        plainText: currentChapter.plainText,
        layout: layout,
        textStyle: TextStyle(
          color: tone.inkColor.withOpacity(0.9),
          fontSize: prefs.fontSize + 1,
          height: 1.0,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

VerticalLayout _vLayout(Size size) {
  final fontSize = ReadingPrefs().fontSize + 1;
  final charH = fontSize * 1.85;
  final colGap = fontSize * 1.5;
  const hPad = 26.0;
  const top = 12.0;
  return VerticalLayout(
    charHeight: charH,
    charWidth: fontSize * 1.0,
    columnGap: colGap,
    lineLeading: fontSize * 0.85,
    contentTop: top,
    contentBottom: size.height - 120,
    contentRight: size.width - hPad,
    contentLeft: hPad,
  );
}

class _VerticalPageShell extends ConsumerWidget {
  const _VerticalPageShell({
    required this.page,
    required this.pageIndex,
    required this.plainText,
    required this.layout,
    required this.textStyle,
  });

  final VerticalPage page;
  final int pageIndex;
  final String plainText;
  final VerticalLayout layout;
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (start, end) = ref.watch(ttsHighlightProvider);
    final hlCols = (start >= 0 && end > start)
        ? columnsForPageRange(
            text: plainText,
            start: start,
            end: end,
            layout: layout,
            pageIndex: pageIndex,
          )
        : const <int>{};

    return RepaintBoundary(
      child: Stack(
        children: [
          VerticalPageView(
            page: page,
            textStyle: textStyle,
            charWidth: layout.charWidth,
            charHeight: layout.charHeight,
            columnGap: layout.columnGap,
            contentTop: layout.contentTop,
            contentRight: layout.contentRight,
          ),
          if (hlCols.isNotEmpty)
            _VerticalHighlight(
              page: page,
              highlightCols: hlCols,
              charWidth: layout.charWidth,
              columnGap: layout.columnGap,
              contentTop: layout.contentTop,
              contentRight: layout.contentRight,
              ink: textStyle.color ?? Colors.black,
            ),
        ],
      ),
    );
  }
}

/// 在竖排页上叠一层半透明高亮：与字形共用同一坐标系。
class _VerticalHighlight extends StatelessWidget {
  const _VerticalHighlight({
    required this.page,
    required this.highlightCols,
    required this.charWidth,
    required this.columnGap,
    required this.contentTop,
    required this.contentRight,
    required this.ink,
  });

  final VerticalPage page;
  final Set<int> highlightCols;
  final double charWidth;
  final double columnGap;
  final double contentTop;
  final double contentRight;
  final Color ink;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _VerticalHighlightPainter(
        page: page,
        cols: highlightCols,
        charWidth: charWidth,
        columnGap: columnGap,
        contentTop: contentTop,
        right: contentRight,
        ink: ink,
      ),
      child: const SizedBox.expand(),
    );
  }
}

class _VerticalHighlightPainter extends CustomPainter {
  _VerticalHighlightPainter({
    required this.page,
    required this.cols,
    required this.charWidth,
    required this.columnGap,
    required this.contentTop,
    required this.right,
    required this.ink,
  });

  final VerticalPage page;
  final Set<int> cols;
  final double charWidth;
  final double columnGap;
  final double contentTop;
  final double right;
  final Color ink;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = ink.withOpacity(0.13)
      ..style = PaintingStyle.fill;
    for (final ci in cols) {
      if (ci < 0 || ci >= page.columns.length) continue;
      final col = page.columns[ci];
      final colRight = right - ci * (charWidth + columnGap);
      final colLeft = colRight - charWidth;
      final colTop = contentTop;
      final colBottom = colTop + col.height;
      canvas.drawRRect(
        RRect.fromLTRBR(
          colLeft - 3,
          colTop - 4,
          colRight + 3,
          colBottom + 4,
          Radius.circular(charWidth * 0.22),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _VerticalHighlightPainter o) =>
      o.cols != cols || o.page != page;
}

/// 横排正文：对齐截图 —— 暖黄纸、章节标题居中、段间距疏朗、末页「本章完」。
class _HorizontalBody extends StatelessWidget {
  const _HorizontalBody({
    super.key,
    required this.chapter,
    required this.fontSize,
    required this.ink,
    required this.slices,
    required this.controller,
    required this.onPageChanged,
  });

  final Chapter chapter;
  final double fontSize;
  final Color ink;
  final List<List<String>> slices;
  final PageController controller;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: controller,
      itemCount: slices.length,
      onPageChanged: onPageChanged,
      itemBuilder: (_, i) {
        final isFirst = i == 0;
        final slice = slices[i];
        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.readingHorizontalPad,
            vertical: AppConstants.readingVerticalPad,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (isFirst) ...[
                Text(
                  chapter.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: ink.withOpacity(0.9),
                    fontSize: fontSize + 4,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 26),
                Container(
                  width: 38,
                  height: 2,
                  decoration: BoxDecoration(
                    color: ink.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
                const SizedBox(height: 22),
              ],
              ...slice.map((p) => Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Text(
                      p,
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                        color: ink.withOpacity(0.88),
                        fontSize: fontSize,
                        height: 2.0,
                        letterSpacing: 0.4,
                      ),
                    ),
                  )),
              if (slice.isEmpty)
                Expanded(
                  child: Center(
                    child: Text(
                      '— 本章完 —',
                      style: TextStyle(
                        color: ink.withOpacity(0.45),
                        fontSize: fontSize - 1,
                        letterSpacing: 3,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _ReadingAppBar extends ConsumerWidget {
  const _ReadingAppBar({
    required this.bookTitle,
    required this.mode,
    required this.plainText,
    required this.onToggleMode,
  });

  final String bookTitle;
  final ReadingMode mode;
  final String plainText;
  final VoidCallback onToggleMode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(readingPrefsProvider);
    final tone = prefs.paperTone;
    final iconColor = tone.inkColor.withOpacity(0.55);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: tone.edgeColor.withOpacity(0.45),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.arrow_back_ios_new_rounded,
                  size: 16, color: iconColor),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              bookTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: tone.inkColor.withOpacity(0.7),
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.6,
              ),
            ),
          ),
          // 听书：开始/暂停 + 语速
          TtsPlayerButton(text: plainText),
          // 横/竖切换
          IconButton(
            onPressed: onToggleMode,
            tooltip: mode == ReadingMode.vertical ? '横排' : '竖排',
            icon: Icon(
              mode == ReadingMode.vertical
                  ? Icons.format_align_left_rounded
                  : Icons.format_align_right_rounded,
              size: 19,
              color: iconColor,
            ),
          ),
          // 字号
          IconButton(
            onPressed: () =>
                ref.read(readingPrefsProvider.notifier).cycleFontSize(),
            icon: Text(
              'A',
              style: TextStyle(
                color: iconColor,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            tooltip: '字号',
          ),
          // 纸张主题
          PopupMenuButton<PaperTone>(
            icon: Icon(Icons.palette_outlined, size: 19, color: iconColor),
            color: Colors.white,
            onSelected: (t) =>
                ref.read(readingPrefsProvider.notifier).setPaper(t),
            itemBuilder: (_) => const [
              PopupMenuItem(value: PaperTone.warm, child: Text('暖黄 · 护眼')),
              PopupMenuItem(value: PaperTone.paper, child: Text('米白 · 纸张')),
              PopupMenuItem(value: PaperTone.night, child: Text('深色 · 夜读')),
            ],
          ),
        ],
      ),
    );
  }
}
