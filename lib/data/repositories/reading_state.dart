import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yuedu/core/constants/app_constants.dart';

/// 阅读偏好：字号 / 纸张主题 / 当前页，跨页面保持
class ReadingPrefs {
  const ReadingPrefs({
    this.fontSizeIndex = 2,
    this.paperTone = PaperTone.warm,
    this.currentPage = 0,
    this.totalPages = 1,
  });

  final int fontSizeIndex;
  final PaperTone paperTone;
  final int currentPage;
  /// 当前章节/文本的真实总页数。由排版结果写入，不再写死 208。
  final int totalPages;

  double get fontSize => AppConstants.fontSizeSteps[fontSizeIndex.clamp(0, AppConstants.fontSizeSteps.length - 1)];

  ReadingPrefs copyWith({int? fontSizeIndex, PaperTone? paperTone, int? currentPage, int? totalPages}) =>
      ReadingPrefs(
        fontSizeIndex: fontSizeIndex ?? this.fontSizeIndex,
        paperTone: paperTone ?? this.paperTone,
        currentPage: currentPage ?? this.currentPage,
        totalPages: totalPages ?? this.totalPages,
      );

  double get progress =>
      totalPages > 1 ? (currentPage.clamp(0, totalPages - 1)) / (totalPages - 1) : 0.0;
}

enum PaperTone {
  warm(0xFFF7ECCB, 0xFFF3E2B8, 0xFF5A4A2E),
  paper(0xFFF4EFE1, 0xFFEDE4CE, 0xFF3F3A30),
  night(0xFF1C1B22, 0xFF14131A, 0xFFC8C2B4);

  const PaperTone(this.paper, this.edge, this.ink);
  final int paper;
  final int edge;
  final int ink;

  Color get paperColor => Color(paper);
  Color get edgeColor => Color(edge);
  Color get inkColor => Color(ink);
}

final readingPrefsProvider =
    StateNotifierProvider<ReadingPrefsNotifier, ReadingPrefs>(
  (_) => ReadingPrefsNotifier(),
);

class ReadingPrefsNotifier extends StateNotifier<ReadingPrefs> {
  ReadingPrefsNotifier() : super(const ReadingPrefs());

  void setFontSize(int i) => state = state.copyWith(fontSizeIndex: i);
  void cycleFontSize() {
    final next = (state.fontSizeIndex + 1) % AppConstants.fontSizeSteps.length;
    state = state.copyWith(fontSizeIndex: next);
  }
  void setPaper(PaperTone t) => state = state.copyWith(paperTone: t);
  void setPage(int p, {int? total}) => state = state.copyWith(
        currentPage: p,
        totalPages: total ?? state.totalPages,
      );
}

/// 书架阅读进度回写：从阅读页退出时把「读到哪」交给书架，
/// 这样封面下的 68% 进度条和 142/208 才能跟着真实位置走。
final bookshelfProgressProvider =
    StateNotifierProvider<BookshelfProgressNotifier, Map<String, BookProgress>>(
  (_) => BookshelfProgressNotifier(),
);

class BookProgress {
  const BookProgress({required this.ratio, required this.total});
  final double ratio;   // 0..1
  final int total;

  int get currentPage => (ratio * total).round().clamp(0, total);
}

class BookshelfProgressNotifier extends StateNotifier<Map<String, BookProgress>> {
  BookshelfProgressNotifier() : super(const {});

  void updateProgress(String bookId, double ratio, int total) {
    state = {...state, bookId: BookProgress(ratio: ratio.clamp(0.0, 1.0), total: total)};
  }

  BookProgress? of(String bookId) => state[bookId];
}

/// 书架多选态
final bookshelfEditModeProvider = StateProvider<bool>((_) => false);
final bookshelfSelectionProvider = StateProvider<Set<String>>((_) => {});
