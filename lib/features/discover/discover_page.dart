import 'package:flutter/material.dart';
import 'package:yuedu/core/theme/app_theme.dart';
import 'package:yuedu/data/repositories/mock_library.dart';
import 'package:yuedu/widgets/book_cover.dart';
import 'package:go_router/go_router.dart';
import 'package:yuedu/widgets/featured_card.dart';

/// 发现页：顶部「发现」标题 + 搜索框 + 每日推荐横滑 + 新书速递横滑
class DiscoverPage extends StatelessWidget {
  const DiscoverPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.pageBg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // 标题
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 18, bottom: 14),
                child: Center(
                  child: Text(
                    '发现',
                    style: TextStyle(
                      color: AppTheme.sectionTitle,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.4,
                    ),
                  ),
                ),
              ),
            ),

            // 搜索框
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  height: 46,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: AppTheme.cardElevation(context),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search_rounded,
                          size: 20, color: AppTheme.textSecondary),
                      const SizedBox(width: 9),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: '搜索书籍',
                            hintStyle: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 14.5,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                          style: const TextStyle(fontSize: 14.5),
                          onSubmitted: (_) {},
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 22)),

            // 每日推荐
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(left: 20),
                child: _SectionHeader(
                  title: '每日推荐',
                  subtitle: '为你挑的今日好书',
                  trailing: TextButton(
                    onPressed: () {},
                    child: const Text('换一批',
                        style: TextStyle(fontSize: 12.5)),
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 172,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: dailyPicks.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 14),
                  itemBuilder: (_, i) => FeaturedCard(book: dailyPicks[i]),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 26)),

            // 新书速递
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _SectionHeader(
                  title: '新书速递',
                  subtitle: '新书推荐',
                  trailing: TextButton(
                    onPressed: () {},
                    child: const Text('查看全部',
                        style: TextStyle(fontSize: 12.5)),
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 150,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: newArrivals.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 14),
                  itemBuilder: (_, i) => GestureDetector(
                    onTap: () => context.push('/read/${newArrivals[i].id}'),
                    child: SizedBox(
                      width: 96,
                      child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BookCover(book: newArrivals[i], showTag: false),
                        const SizedBox(height: 8),
                        Text(
                          newArrivals[i].title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          newArrivals[i].author,
                          maxLines: 1,
                          style: const TextStyle(
                            fontSize: 10.5,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            ),

            // 三张精选封面卡：对齐截图里「新书速递」下方那排静态卡
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    for (final b in newArrivals.take(3))
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: GestureDetector(
                            onTap: () => context.push('/read/${b.id}'),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: AppTheme.radius14,
                                boxShadow: AppTheme.cardElevation(context),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  BookCover(book: b, showTag: false),
                                  const SizedBox(height: 8),
                                  Text(
                                    b.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    b.author,
                                    maxLines: 1,
                                    style: const TextStyle(
                                      fontSize: 9.5,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle, this.trailing});

  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: AppTheme.sectionTitle,
                fontSize: 17,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 11.5,
              ),
            ),
          ],
        ),
        const Spacer(),
        if (trailing != null) trailing!,
      ],
    );
  }

}
