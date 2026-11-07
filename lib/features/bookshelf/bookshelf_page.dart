import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yuedu/core/theme/app_theme.dart';
import 'package:yuedu/data/repositories/mock_library.dart';
import 'package:yuedu/data/repositories/reading_state.dart';
import 'package:yuedu/widgets/bookshelf_tile.dart';

/// 书架页：3 列网格 + 右上「编辑」切换多选 + 编辑态底部删除/置顶栏
class BookshelfPage extends ConsumerWidget {
  const BookshelfPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editing = ref.watch(bookshelfEditModeProvider);
    final selected = ref.watch(bookshelfSelectionProvider);

    return Scaffold(
      backgroundColor: AppTheme.pageBg,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        // 截图里书架页顶部只有右对齐「编辑」，底部 tab 已显示「书架」，故不重复标题
        title: editing ? Text('已选 ${selected.length}') : null,
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () {
                if (editing && selected.isEmpty) {
                  ref.read(bookshelfEditModeProvider.notifier).state = false;
                } else {
                  ref.read(bookshelfEditModeProvider.notifier).state = !editing;
                  if (editing) {
                    ref.read(bookshelfSelectionProvider.notifier).state = {};
                  }
                }
              },
              child: Text(
                editing ? '完成' : '编辑',
                style: TextStyle(
                  color: AppTheme.sectionTitle,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GridView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 96),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 18,
              crossAxisSpacing: 14,
              childAspectRatio: 0.62,
            ),
            itemCount: bookshelf.length,
            itemBuilder: (_, i) => BookshelfTile(book: bookshelf[i]),
          ),
        ),
      ),
      bottomNavigationBar: editing && selected.isNotEmpty
          ? SafeArea(
              child: Container(
                height: 64,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 12,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    _ActionBtn(
                      icon: Icons.push_pin_outlined,
                      label: '置顶',
                      onTap: () {
                                                ref.read(bookshelfSelectionProvider.notifier).state = {};
                        ref.read(bookshelfEditModeProvider.notifier).state = false;
                      },
                    ),
                    _ActionBtn(
                      icon: Icons.delete_outline_rounded,
                      label: '删除',
                      isDanger: true,
                      onTap: () {
                                                ref.read(bookshelfSelectionProvider.notifier).state = {};
                        ref.read(bookshelfEditModeProvider.notifier).state = false;
                      },
                    ),
                    const Spacer(),
                    Text(
                      '${selected.length} 本已选',
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }
}

class _ActionBtn extends StatelessWidget {
  const _ActionBtn({required this.icon, required this.label, this.isDanger = false, this.onTap});

  final IconData icon;
  final String label;
  final bool isDanger;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = isDanger ? const Color(0xFFE8798C) : AppTheme.brand;
    return Padding(
      padding: const EdgeInsets.only(right: 22),
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 21, color: color),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 11.5, color: color)),
          ],
        ),
      ),
    );
  }
}
