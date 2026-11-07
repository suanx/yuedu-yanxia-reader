import 'package:flutter/material.dart';
import 'package:yuedu/core/theme/app_theme.dart';
import 'package:yuedu/data/models/book.dart';
import 'package:go_router/go_router.dart';
import 'package:yuedu/widgets/book_cover.dart';

/// 「每日推荐」横向大卡：左文右封面，卡片白底 + 淡蓝光晕
class FeaturedCard extends StatelessWidget {
  const FeaturedCard({super.key, required this.book, this.onTap});

  final Book book;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => context.push('/read/${book.id}'),
      child: Container(
        width: 268,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: AppTheme.radius18,
          boxShadow: AppTheme.cardElevation(context),
          // 右下角一点冷蓝晕，对齐设计稿的轻盈感
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Color(0xFFF4F8FF)],
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '每日推荐',
                    style: TextStyle(
                      color: AppTheme.sectionTitle,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    book.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    book.author,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppTheme.brandSoft,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.play_arrow_rounded,
                            size: 15, color: AppTheme.brand),
                        const SizedBox(width: 3),
                        Text(
                          '开始阅读',
                          style: TextStyle(
                            color: AppTheme.brand,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            BookCover(book: book, width: 84),
          ],
        ),
      ),
    );
  }
}
