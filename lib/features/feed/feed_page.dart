import 'package:flutter/material.dart';
import 'package:yuedu/core/constants/app_constants.dart';
import 'package:yuedu/core/theme/app_theme.dart';

/// 「看一看」：短内容推荐流（占位，结构同发现页，接接口即可）
class FeedPage extends StatelessWidget {
  const FeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.pageBg,
      appBar: AppBar(title: const Text('看一看')),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: 6,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (_, i) => Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.cardBg,
            borderRadius: AppTheme.radius18,
            boxShadow: AppTheme.cardElevation(context),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: AppTheme.radius10,
                  gradient: LinearGradient(
                    colors: coverGradients[i % coverGradients.length],
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 14,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8EAF0),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 9),
                    Container(
                      height: 11,
                      width: 120,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F1F5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
