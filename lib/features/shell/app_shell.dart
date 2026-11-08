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

  static const _pages = [
    DiscoverPage(),
    BookshelfPage(),
    FeedPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(tabIndexProvider);

    // 只用一层 Scaffold（各页面自带），外层不再套 Scaffold：
    //   · 之前「外层 Scaffold + Stack 里 loose 约束的页面层」导致页面塌缩成
    //     0 高，CustomScrollView 的 sliver 全都不 build → 真机整页空白；
    //   · 底栏也改成 Positioned(bottom: 0)，避免 bottomNavigationBar 在
    //     某些机型上被放到屏幕中部。
    // 页面由 PageBackground 的 Positioned.fill 拿到 tight 约束，必然渲染。
    return PageBackground(
      child: Stack(
        children: [
          Positioned.fill(child: _pages[index]),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: GlassBottomBar(
              index: index,
              onTap: (i) => ref.read(tabIndexProvider.notifier).state = i,
              tabs: _tabs,
            ),
          ),
        ],
      ),
    );
  }
}
