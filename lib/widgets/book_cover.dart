import 'package:flutter/material.dart';
import 'package:yuedu/core/constants/app_constants.dart';
import 'package:yuedu/core/theme/app_theme.dart';
import 'package:yuedu/data/models/book.dart';

/// 书籍封面。比例 3:4，带圆角 + 柔和阴影 + 可选角标。
class BookCover extends StatelessWidget {
  const BookCover({
    super.key,
    required this.book,
    this.width,
    this.showTag = true,
  });

  final Book book;
  final double? width;
  final bool showTag;

  @override
  Widget build(BuildContext context) {
    final seed = book.gradientSeed % coverGradients.length;
    final grad = coverGradients[seed];

    final image = book.coverAsset != null
        ? Image.asset(
            'assets/covers/${book.coverAsset}',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _grad(grad),
          )
        : _grad(grad);

    Widget content = AspectRatio(
      aspectRatio: 3 / 4,
      child: ClipRRect(
        borderRadius: AppTheme.radius14,
        child: Stack(
          fit: StackFit.expand,
          children: [
            image,
            // 顶部淡淡高光，模拟书封质感
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.22),
                    Colors.transparent,
                    Colors.black.withOpacity(0.08),
                  ],
                  stops: const [0.0, 0.45, 1.0],
                ),
              ),
            ),
            if (showTag && book.tag != null)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.92),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    book.tag!,
                    style: const TextStyle(
                      color: AppTheme.brand,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    if (width != null) {
      content = SizedBox(width: width, child: content);
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: AppTheme.radius14,
        boxShadow: AppTheme.cardElevation(context),
      ),
      child: content,
    );
  }

  static Widget _grad(List<Color> g) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: g,
          ),
        ),
        child: Center(
          child: Icon(
            Icons.auto_stories_rounded,
            color: Colors.white.withOpacity(0.85),
            size: 30,
          ),
        ),
      );
}
