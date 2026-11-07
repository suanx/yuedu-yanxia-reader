import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yuedu/core/constants/app_constants.dart';
import 'package:yuedu/core/theme/app_theme.dart';
import 'package:yuedu/data/models/book.dart';
import 'package:yuedu/data/repositories/reading_state.dart';
import 'package:yuedu/widgets/book_cover.dart';

/// 书架网格单元：封面 + 书名 + 作者 + 进度条 + 「68% · 142/208」。
///
/// 点封面 → 阅读页，并把 bookId 带过去，阅读页翻页时会把进度回写到
/// [bookshelfProgressProvider]，所以书架上的百分比和页码会实时跟着走。
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
        // 书架 → 阅读页：起始页按「已读比例 × 总页数」定位，进度无缝衔接
        final start = total > 1
            ? ((ratio * (total - 1)).round().clamp(0, total - 1))
            : 0;
        context.push(
          '/read/${book.id}?page=$start',
          extra: book,
        );
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
        children: [
          // 封面区
          SizedBox(
            height: 172,
            child: Stack(
              children: [
                Positioned.fill(child: BookCover(book: book)),
                if (editing)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: AnimatedScale(
                      scale: 1.0,
                      duration: AppConstants.animFast,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: selected ? AppTheme.brand : Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selected
                                ? AppTheme.brand
                                : Colors.white.withOpacity(0.9),
                            width: 1.6,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.12),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: selected
                            ? const Icon(Icons.check_rounded,
                                size: 15, color: Colors.white)
                            : null,
                      ),
                    ),
                  ),
                // 读完角标
                if (finished && !editing)
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7BD88F),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: const Text(
                        '已读',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 9),
          Text(
            book.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            book.author,
            maxLines: 1,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 4,
              backgroundColor: const Color(0xFFE8EAF0),
              valueColor: AlwaysStoppedAnimation<Color>(
                finished ? const Color(0xFF7BD88F) : AppTheme.brand,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(ratio * 100).round()}%',
                style: TextStyle(
                  color: finished
                      ? const Color(0xFF7BD88F)
                      : AppTheme.brand,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '$current/$total',
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
