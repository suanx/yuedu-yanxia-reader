import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yuedu/core/constants/app_constants.dart';
import 'package:yuedu/core/theme/app_theme.dart';
import 'package:yuedu/data/models/book.dart';
import 'package:yuedu/widgets/book_cover.dart';
import 'package:yuedu/widgets/glass.dart';

/// 「每日推荐」横向大卡：左文右封面，玻璃底 + 淡蓝光晕。
///
/// 卡片内不再重复写一遍「每日推荐」（分区标题已经写过），
/// 只保留书名 / 作者 / 开始阅读，减少视觉噪音。
class FeaturedCard extends StatelessWidget {
  const FeaturedCard({super.key, required this.book, this.onTap});

  final Book book;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => context.push('/read/${book.id}'),
      child: GlassCard(
        width: 262,
        padding: const EdgeInsets.all(AppConstants.s16),
        radius: 20,
        opacity: 0.66,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    book.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.title.copyWith(fontSize: 15),
                  ),
                  const SizedBox(height: AppConstants.s6),
                  Text(book.author, style: AppText.caption),
                  const SizedBox(height: AppConstants.s16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.brandSoft.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.play_arrow_rounded,
                            size: 14, color: AppTheme.brand),
                        const SizedBox(width: 3),
                        Text('开始阅读', style: AppText.action),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppConstants.s12),
            BookCover(book: book, width: 80),
          ],
        ),
      ),
    );
  }
}
