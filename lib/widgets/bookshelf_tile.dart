import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yuedu/core/constants/app_constants.dart';
import 'package:yuedu/core/theme/app_theme.dart';
import 'package:yuedu/data/models/book.dart';
import 'package:yuedu/data/repositories/reading_state.dart';
import 'package:yuedu/widgets/book_cover.dart';

/// 书架网格单元：封面 + 书名 + 作者 + 进度条 + 「0% · 0/180」。
///
/// 真机上旧版书名被裁、上下两排叠在一起，根因是封面写死 height 172，
/// 而 3 列网格的 cell 只有约 161 高 —— 封面直接把文字挤出了边界。
/// 现在封面按列宽走 3:4 自适应，网格比例同步放宽到 0.48，不再溢出。
class BookshelfTile extends ConsumerWidget {
  const BookshelfTile({super.key, required this.book});

  final Book book;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editing = ref.watch(bookshelfEditModeProvider);
    final selected = ref.watch(bookshelfSelectionProvider).contains(book.id);
    final live = ref.watch(bookshelfProgressProvider)[book.id];
    final ratio = live?.ratio ?? book.progress;
    final total = live?.total ?? book.totalPages;
    final current = (ratio * total).round().clamp(0, total);
    final finished = ratio >= 1.0;

    return GestureDetector(
      onTap: () {
        if (editing) {
          ref.read(bookshelfSelectionProvider.notifier).update((s) {
            final next = Set<String>.from(s);
            if (selected) {
              next.remove(book.id);
            } else {
              next.add(book.id);
            }
            return next;
          });
          return;
        }
        final start = total > 1
            ? ((ratio * (total - 1)).round().clamp(0, total - 1))
            : 0;
        context.push('/read/${book.id}?page=$start', extra: book);
      },
      onLongPress: () {
        if (!editing) {
          ref.read(bookshelfEditModeProvider.notifier).state = true;
          ref.read(bookshelfSelectionProvider.notifier).update((s) {
            final next = Set<String>.from(s)..add(book.id);
            return next;
          });
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 封面：按列宽自适应，不再写死高度
          AspectRatio(
            aspectRatio: 3 / 4,
            child: Stack(
              children: [
                Positioned.fill(child: BookCover(book: book)),
                if (editing)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: selected
                            ? AppTheme.brand
                            : Colors.white.withOpacity(0.85),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selected
                              ? AppTheme.brand
                              : Colors.white.withOpacity(0.9),
                          width: 1.5,
                        ),
                      ),
                      child: selected
                          ? const Icon(Icons.check_rounded,
                              size: 14, color: Colors.white)
                          : null,
                    ),
                  ),
                if (finished && !editing)
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7BD88F).withOpacity(0.92),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.7),
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        '已读',
                        style: AppText.micro.copyWith(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.s8),
          Text(
            book.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppText.title,
          ),
          const SizedBox(height: 2),
          Text(
            book.author,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppText.micro,
          ),
          const SizedBox(height: AppConstants.s6),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 3,
              backgroundColor: const Color(0xFFE8EAF0),
              valueColor: AlwaysStoppedAnimation<Color>(
                finished ? const Color(0xFF7BD88F) : AppTheme.brand,
              ),
            ),
          ),
          const SizedBox(height: 3),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(ratio * 100).round()}%',
                style: AppText.micro.copyWith(
                  color: finished
                      ? const Color(0xFF5FB877)
                      : AppTheme.brand,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text('$current/$total', style: AppText.micro),
            ],
          ),
        ],
      ),
    );
  }
}
