import 'package:flutter/material.dart';
import 'package:yuedu/core/constants/app_constants.dart';
import 'package:yuedu/core/theme/app_theme.dart';
import 'package:yuedu/widgets/glass.dart';

/// 「看一看」：短内容推荐流（占位，结构同发现页，接接口即可）
class FeedPage extends StatelessWidget {
  const FeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            const GlassHeader(title: '看一看'),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                  AppConstants.pagePadding,
                  AppConstants.s4,
                  AppConstants.pagePadding,
                  AppConstants.bottomSafe,
                ),
                itemCount: 6,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppConstants.s12),
                itemBuilder: (_, i) => GlassCard(
                  radius: 18,
                  opacity: 0.58,
                  padding: const EdgeInsets.all(AppConstants.s12),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius: AppTheme.radius10,
                          gradient: LinearGradient(
                            colors: coverGradients[i % coverGradients.length],
                          ),
                        ),
                      ),
                      const SizedBox(width: AppConstants.s12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _Bar(width: double.infinity, height: 9),
                            const SizedBox(height: AppConstants.s8),
                            _Bar(width: 110, height: 8, faint: true),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.width, required this.height, this.faint = false});

  final double width;
  final double height;
  final bool faint;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: faint ? const Color(0xFFEFF1F6) : const Color(0xFFE6E9F1),
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}
