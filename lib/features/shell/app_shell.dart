import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yuedu/core/theme/app_theme.dart';
import 'package:yuedu/features/discover/discover_page.dart';
import 'package:yuedu/features/bookshelf/bookshelf_page.dart';
import 'package:yuedu/features/feed/feed_page.dart';
import 'package:yuedu/features/profile/profile_page.dart';

final tabIndexProvider = StateProvider<int>((_) => 0);

class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  static const _tabs = [
    _TabData('发现', Icons.explore_outlined, Icons.explore_rounded),
    _TabData('书架', Icons.auto_stories_outlined, Icons.auto_stories_rounded),
    _TabData('看一看', Icons.visibility_outlined, Icons.visibility_rounded),
    _TabData('我', Icons.person_outline_rounded, Icons.person_rounded),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(tabIndexProvider);
    return Scaffold(
      body: IndexedStack(
        index: index,
        children: const [
          DiscoverPage(),
          BookshelfPage(),
          FeedPage(),
          ProfilePage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (i) => ref.read(tabIndexProvider.notifier).state = i,
        items: [
          for (final t in _tabs)
            BottomNavigationBarItem(
              icon: Icon(t.icon),
              activeIcon: Icon(t.active),
              label: t.label,
            ),
        ],
      ),
    );
  }
}

class _TabData {
  const _TabData(this.label, this.icon, this.active);
  final String label;
  final IconData icon;
  final IconData active;
}
