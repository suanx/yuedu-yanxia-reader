import 'package:flutter/foundation.dart';

/// 书籍实体。
/// [coverAsset] 为空时使用 [gradientSeed] 生成渐变封面，避免缺图崩溃。
@immutable
class Book {
  const Book({
    required this.id,
    required this.title,
    required this.author,
    this.coverAsset,
    this.tag,
    this.gradientSeed = 0,
    this.progress = 0.0,
    this.totalPages = 208,
    this.currentPage = 0,
  });

  final String id;
  final String title;
  final String author;
  /// assets/covers/ 下的文件名，可空
  final String? coverAsset;
  /// 角标，如「新书」「推荐」，空则不显示
  final String? tag;
  final int gradientSeed;
  final double progress;
  final int totalPages;
  final int currentPage;

  Book copyWith({int? currentPage, double? progress}) => Book(
        id: id,
        title: title,
        author: author,
        coverAsset: coverAsset,
        tag: tag,
        gradientSeed: gradientSeed,
        totalPages: totalPages,
        currentPage: currentPage ?? this.currentPage,
        progress: progress ?? this.progress,
      );
}
