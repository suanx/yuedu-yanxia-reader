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

    // 只渲染当前页，不用 IndexedStack：
    //   · IndexedStack 把所有页面包在 Offstage 里，配合 Stack 的宽松约束
    //     曾导致页面层塌缩成 0 高，真机上表现为「整页空白、只剩底栏」；
    //   · 现在页面由 [PageBackground] 的 Positioned.fill 拿到 tight 约束，
    //     且不在任何 Offstage 之下，界面冒烟测试也能直接断言到内容节点。
    // 代价是切换 tab 时页面重建（滚动位置不保留），此处可接受。
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PageBackground(child: _pages[index]),
      bottomNavigationBar: GlassBottomBar(
        index: index,
        onTap: (i) => ref.read(tabIndexProvider.notifier).state = i,
        tabs: _tabs,
      ),
    );
  }
}
