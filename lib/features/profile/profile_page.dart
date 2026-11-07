import 'package:flutter/material.dart';
import 'package:yuedu/core/constants/app_constants.dart';
import 'package:yuedu/core/theme/app_theme.dart';
import 'package:yuedu/widgets/glass.dart';

/// 「我」：设置入口占位
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = const [
      (Icons.headphones_rounded, '听书设置', '端侧 TTS · 未配置'),
      (Icons.palette_outlined, '阅读主题', '暖黄 / 米白 / 夜读'),
      (Icons.cloud_sync_outlined, '书库同步', '未登录'),
      (Icons.notifications_outlined, '阅读提醒', ''),
      (Icons.help_outline_rounded, '帮助与反馈', ''),
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            const GlassHeader(title: '我'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppConstants.pagePadding,
                  AppConstants.s4,
                  AppConstants.pagePadding,
                  AppConstants.bottomSafe,
                ),
                children: [
                  GlassCard(
                    radius: 18,
                    opacity: 0.66,
                    padding: const EdgeInsets.all(AppConstants.s16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: AppTheme.brandSoft,
                          child: Icon(Icons.person_rounded,
                              size: 28, color: AppTheme.brand),
                        ),
                        const SizedBox(width: AppConstants.s12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('书友',
                                style: AppText.title.copyWith(fontSize: 15)),
                            const SizedBox(height: 3),
                            Text('点击登录，同步书架与听书进度',
                                style: AppText.caption),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppConstants.s16),
                  for (final e in items)
                    GlassCard(
                      margin: const EdgeInsets.only(
                        bottom: AppConstants.s12,
                      ),
                      radius: 16,
                      opacity: 0.56,
                      padding: EdgeInsets.zero,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.s16,
                          vertical: AppConstants.s4,
                        ),
                        leading: Icon(e.$1, color: AppTheme.brand, size: 20),
                        title: Text(e.$2, style: AppText.title),
                        subtitle: e.$3.isNotEmpty
                            ? Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(e.$3, style: AppText.caption),
                              )
                            : null,
                        trailing: const Icon(Icons.chevron_right_rounded,
                            size: 19, color: AppTheme.textSecondary),
                        onTap: () {},
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
