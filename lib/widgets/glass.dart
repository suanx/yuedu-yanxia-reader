import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:yuedu/core/theme/app_theme.dart';

/// 檐下 · 玻璃拟态基础组件
///
/// 毛玻璃要「看得出来」，背后必须有可模糊的内容，所以 [PageBackdrop]
/// 先铺一层极淡的蓝紫色光斑，卡片 / 底栏再用 [BackdropFilter] 去糊它。
/// 光斑透明度都压在 0.12 以下，只提供层次，不抢文字。

// ---------------------------------------------------------------- 背景

class PageBackdrop extends StatelessWidget {
  const PageBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: const [
        // 冷白底，比纯 #FFF 多一点层次
        SizedBox.expand(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFF8FAFF), Color(0xFFF2F5FC)],
              ),
            ),
          ),
        ),
        Positioned(top: -90, left: -70, child: _Blob(color: Color(0xFF3D7DFF), size: 300, opacity: 0.13)),
        Positioned(top: 260, right: -130, child: _Blob(color: Color(0xFF9B8BF5), size: 290, opacity: 0.10)),
        Positioned(bottom: 110, left: -120, child: _Blob(color: Color(0xFF6CD3E6), size: 270, opacity: 0.09)),
      ],
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.color, required this.size, required this.opacity});

  final Color color;
  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color.withOpacity(opacity), color.withOpacity(0)],
            stops: const [0.0, 1.0],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- 页面容器

/// 铺满可用空间的「光斑背景 + 页面内容」容器。
///
/// 关键：两个 child 都用 [Positioned.fill]，因此页面层拿到的是 tight 约束。
/// 直接把 IndexedStack 丢进 Stack 会收到 loose 约束而塌缩成 0 高，
/// 表现为「整页空白、只剩底栏」——这个坑踩过一次，别再退回去。
class PageBackground extends StatelessWidget {
  const PageBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        children: [
          const Positioned.fill(child: PageBackdrop()),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------- 玻璃卡片

/// 通用玻璃容器。用于搜索框、推荐大卡、看一看卡片、我的设置项等。
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.margin,
    this.padding = const EdgeInsets.all(14),
    this.radius = 18,
    this.blur = 16,
    this.opacity = 0.62,
    this.borderOpacity = 0.72,
  });

  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry padding;
  final double radius;
  final double blur;
  final double opacity;
  final double borderOpacity;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(radius);
    return Container(
      width: width,
      height: height,
      margin: margin,
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(opacity),
                  Colors.white.withOpacity(opacity * 0.55),
                ],
              ),
              border: Border.all(
                color: Colors.white.withOpacity(borderOpacity),
                width: 1,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0F22305A),
                  blurRadius: 16,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- 标题条

/// 页面顶部居中标题（发现 / 看一看 / 我 共用），统一字重与上下留白。
class GlassHeader extends StatelessWidget {
  const GlassHeader({
    super.key,
    required this.title,
    this.trailing,
    this.top = 10,
    this.bottom = 16,
  });

  final String title;
  final Widget? trailing;
  final double top;
  final double bottom;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(18, top, 18, bottom),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: Text(title, style: AppText.display),
          ),
          if (trailing != null)
            Align(
              alignment: Alignment.centerRight,
              child: trailing!,
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------- 底部导航

class GlassTabItem {
  const GlassTabItem(this.label, this.icon, this.activeIcon);

  final String label;
  final IconData icon;
  final IconData activeIcon;
}

/// 毛玻璃底栏：半透明白 + 高斯模糊 + 细白边，选中项一枚淡蓝胶囊。
class GlassBottomBar extends StatelessWidget {
  const GlassBottomBar({
    super.key,
    required this.index,
    required this.onTap,
    required this.tabs,
  });

  final int index;
  final ValueChanged<int> onTap;
  final List<GlassTabItem> tabs;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    const radius = BorderRadius.vertical(top: Radius.circular(22));

    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.only(top: 8, bottom: 8 + bottomInset),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.58),
            borderRadius: radius,
            border: Border(
              top: BorderSide(
                color: Colors.white.withOpacity(0.8),
                width: 1,
              ),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1422305A),
                blurRadius: 20,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: Row(
            children: [
              for (int i = 0; i < tabs.length; i++)
                Expanded(child: _GlassTabButton(
                  item: tabs[i],
                  selected: i == index,
                  onTap: () => onTap(i),
                )),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassTabButton extends StatelessWidget {
  const _GlassTabButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final GlassTabItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppTheme.brand : AppTheme.textSecondary;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: selected
                ? AppTheme.brand.withOpacity(0.10)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                selected ? item.activeIcon : item.icon,
                size: 21,
                color: color,
              ),
              const SizedBox(height: 3),
              Text(
                item.label,
                style: AppText.micro.copyWith(
                  color: color,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
