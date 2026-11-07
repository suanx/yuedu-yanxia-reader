import 'package:flutter/material.dart';
import 'package:yuedu/core/theme/app_theme.dart';

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
      backgroundColor: AppTheme.pageBg,
      appBar: AppBar(title: const Text('我')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppTheme.cardBg,
              borderRadius: AppTheme.radius18,
              boxShadow: AppTheme.cardElevation(context),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppTheme.brandSoft,
                  child: Icon(Icons.person_rounded,
                      size: 30, color: AppTheme.brand),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('书友',
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w700)),
                    SizedBox(height: 4),
                    Text('点击登录，同步书架与听书进度',
                        style: TextStyle(
                            fontSize: 12, color: AppTheme.textSecondary)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          ...items.map((e) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: AppTheme.cardBg,
                  borderRadius: AppTheme.radius14,
                  boxShadow: AppTheme.cardElevation(context),
                ),
                child: ListTile(
                  leading: Icon(e.$1, color: AppTheme.brand, size: 21),
                  title: Text(e.$2,
                      style: const TextStyle(
                          fontSize: 14.5, fontWeight: FontWeight.w500)),
                  subtitle: e.$3.isNotEmpty
                      ? Text(e.$3,
                          style: const TextStyle(
                              fontSize: 11.5, color: AppTheme.textSecondary))
                      : null,
                  trailing: const Icon(Icons.chevron_right_rounded,
                      color: AppTheme.textSecondary),
                  onTap: () {},
                ),
              )),
        ],
      ),
    );
  }
}
