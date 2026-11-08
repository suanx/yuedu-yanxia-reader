import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yuedu/features/bookshelf/bookshelf_page.dart';
import 'package:yuedu/features/discover/discover_page.dart';
import 'package:yuedu/features/feed/feed_page.dart';
import 'package:yuedu/features/profile/profile_page.dart';
import 'package:yuedu/widgets/glass.dart';

final tabIndexProvider = StateProvider<int>((_) => 0);

class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  static const _tabs = [
    GlassTabItem('发现', Icons.explore_outlined, Icons.explore_rounded),
    GlassTabItem('书架', Icons.auto_stories_outlined, Icons.auto_stories_rounded),
    GlassTabItem('看一看', Icons.visibility_outlined, Icons.visibility_rounded),
    GlassTabItem('我', Icons.person_outline_rounded, Icons.person_rounded),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(tabIndexProvider);

    // 页面层必须由 [PageBackground] 用 Positioned.fill 包住，
    // 否则 IndexedStack 在宽松约束下会塌缩，四个 tab 的内容全部不渲染。
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PageBackground(
        child: IndexedStack(
          index: index,
          children: const [
            DiscoverPage(),
            BookshelfPage(),
            FeedPage(),
            ProfilePage(),
          ],
        ),
      ),
      bottomNavigationBar: GlassBottomBar(
        index: index,
        onTap: (i) => ref.read(tabIndexProvider.notifier).state = i,
        tabs: _tabs,
      ),
    );
  }
}
