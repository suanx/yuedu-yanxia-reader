import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yuedu/core/constants/app_constants.dart';
import 'package:yuedu/core/theme/app_theme.dart';
import 'package:yuedu/data/repositories/mock_library.dart';
import 'package:yuedu/data/repositories/reading_state.dart';
import 'package:yuedu/widgets/bookshelf_tile.dart';
import 'package:yuedu/widgets/glass.dart';

/// 书架页：3 列网格 + 右上「编辑」多选 + 编辑态玻璃操作浮层
///
/// 三处修正：
///   · 去掉嵌套 AppBar，标题条与另外三页统一
///   · childAspectRatio 0.62 → 0.48，配合自适应封面，彻底解决裁切/重叠
///   · 编辑操作栏从 Scaffold.bottomNavigationBar 改成浮层，避免双底栏打架
class BookshelfPage extends ConsumerWidget {
  const BookshelfPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editing = ref.watch(bookshelfEditModeProvider);
    final selected = ref.watch(bookshelfSelectionProvider);
    const hPad = AppConstants.pagePadding;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Stack(
          children: [
            // 必须 Positioned.fill：Stack 给非定位 child 的是宽松约束，
            // 里面的 Expanded(GridView) 会拿不到确定高度，格子全不 build。
            Positioned.fill(
              child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: hPad),
              child: Column(
                children: [
                  GlassHeader(
                    title: editing ? '已选 ${selected.length}' : '书架',
                    trailing: GestureDetector(
                      onTap: () {
                        if (editing && selected.isEmpty) {
                          ref.read(bookshelfEditModeProvider.notifier).state =
                              false;
                        } else {
                          ref.read(bookshelfEditModeProvider.notifier).state =
                              !editing;
                          if (editing) {
                            ref
                                .read(bookshelfSelectionProvider.notifier)
                                .state = {};
                          }
                        }
                      },
                      child: Text(
                        editing ? '完成' : '编辑',
                        style: AppText.action,
                      ),
                    ),
                  ),
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.only(
                        top: AppConstants.s4,
                        bottom: AppConstants.bottomSafe,
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: AppConstants.s20,
                        crossAxisSpacing: AppConstants.gridGap,
                        childAspectRatio: 0.48,
                      ),
                      itemCount: bookshelf.length,
                      itemBuilder: (_, i) => BookshelfTile(book: bookshelf[i]),
                    ),
                  ),
                ],
              ),
            ),
            ),
            if (editing && selected.isNotEmpty)
              Positioned(
                left: hPad,
                right: hPad,
                bottom: 84,
                child: GlassCard(
                  radius: 18,
                  opacity: 0.76,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.s16,
                    vertical: AppConstants.s8,
                  ),
                  child: Row(
                    children: [
                      _ActionBtn(
                        icon: Icons.push_pin_outlined,
                        label: '置顶',
                        onTap: () => _reset(ref),
                      ),
                      _ActionBtn(
                        icon: Icons.delete_outline_rounded,
                        label: '删除',
                        isDanger: true,
                        onTap: () => _reset(ref),
                      ),
                      const Spacer(),
                      Text('${selected.length} 本已选',
                          style: AppText.caption),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _reset(WidgetRef ref) {
    ref.read(bookshelfSelectionProvider.notifier).state = {};
    ref.read(bookshelfEditModeProvider.notifier).state = false;
  }
}

class _ActionBtn extends StatelessWidget {
  const _ActionBtn({
    required this.icon,
    required this.label,
    this.isDanger = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isDanger;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = isDanger ? const Color(0xFFE8798C) : AppTheme.brand;
    return Padding(
      padding: const EdgeInsets.only(right: AppConstants.s20),
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 3),
            Text(label, style: AppText.micro.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}
