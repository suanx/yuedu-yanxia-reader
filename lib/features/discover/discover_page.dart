import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yuedu/core/constants/app_constants.dart';
import 'package:yuedu/core/theme/app_theme.dart';
import 'package:yuedu/data/models/book.dart';
import 'package:yuedu/data/repositories/mock_library.dart';
import 'package:yuedu/widgets/book_cover.dart';
import 'package:yuedu/widgets/featured_card.dart';
import 'package:yuedu/widgets/glass.dart';

/// 发现页：居中标题 + 玻璃搜索框 + 每日推荐横滑 + 新书速递横滑
///
/// 旧版在「新书速递」下面又重复摆了一排同样的三张卡，是页面显得杂的主因，
/// 这里整块删掉；所有间距只走 [AppConstants] 的刻度，字号只走 [AppText]。
class DiscoverPage extends StatelessWidget {
  const DiscoverPage({super.key});

  @override
  Widget build(BuildContext context) {
    const hPad = AppConstants.pagePadding;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(child: GlassHeader(title: '发现')),

            // 搜索框：半透明玻璃 + 高斯模糊
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: hPad),
                child: GlassCard(
                  height: 44,
                  radius: 15,
                  opacity: 0.60,
                  blur: 14,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    children: [
                      Icon(Icons.search_rounded,
                          size: 19, color: AppTheme.textSecondary),
                      const SizedBox(width: AppConstants.s8),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: '搜索书籍',
                            hintStyle: AppText.body.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          style: AppText.body,
                          onSubmitted: (_) {},
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: AppConstants.s24)),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: hPad),
                child: _SectionHeader(
                  title: '每日推荐',
                  subtitle: '为你挑的今日好书',
                  action: '换一批',
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppConstants.s12)),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 158,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: hPad),
                  itemCount: dailyPicks.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(width: AppConstants.s12),
                  itemBuilder: (_, i) => FeaturedCard(book: dailyPicks[i]),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: AppConstants.s28)),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: hPad),
                child: _SectionHeader(
                  title: '新书速递',
                  subtitle: '新书推荐',
                  action: '查看全部',
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppConstants.s12)),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 166,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: hPad),
                  itemCount: newArrivals.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(width: AppConstants.s12),
                  itemBuilder: (_, i) => _NewArrivalCard(book: newArrivals[i]),
                ),
              ),
            ),

            // 底栏是浮层，给内容留出滚动余量
            const SliverToBoxAdapter(
                child: SizedBox(height: AppConstants.bottomSafe)),
          ],
        ),
      ),
    );
  }
}

class _NewArrivalCard extends StatelessWidget {
  const _NewArrivalCard({required this.book});

  final Book book;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/read/${book.id}'),
      child: SizedBox(
        width: 92,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BookCover(book: book, showTag: false),
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
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.action,
  });

  final String title;
  final String subtitle;
  final String action;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppText.section),
            const SizedBox(height: 3),
            Text(subtitle, style: AppText.caption),
          ],
        ),
        const Spacer(),
        GestureDetector(
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.only(bottom: 1),
            child: Text(action, style: AppText.action),
          ),
        ),
      ],
    );
  }
}
