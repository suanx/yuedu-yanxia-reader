import 'package:flutter/material.dart';

/// 檐下 · 视觉基调
///
/// 冷白玻璃底 + 克莱因蓝点缀 + 暖黄阅读纸。
/// 所有字号 / 字重 / 行高统一收敛到 [AppText]，避免各页面各写一套导致
/// 真机上「字忽大忽小、行忽松忽紧」的杂乱感。
class AppTheme {
  AppTheme._();

  // ---- 品牌 ----
  static const brand = Color(0xFF3D7DFF);
  static const brandSoft = Color(0xFFE8F0FE);

  // ---- 背景 ----
  static const pageBg = Color(0xFFF5F6FA);
  static const cardBg = Colors.white;
  static const cardShadow = Color(0x0A22305A);

  // ---- 文字 ----
  static const textPrimary = Color(0xFF1F2937);
  static const textSecondary = Color(0xFF8A94A6);
  static const sectionTitle = Color(0xFF3D7DFF);

  // ---- 阅读纸 ----
  static const paper = Color(0xFFF7ECCB);
  static const paperEdge = Color(0xFFF3E2B8);
  static const ink = Color(0xFF5A4A2E);
  static const inkSoft = Color(0xFF8A7854);

  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: pageBg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: brand,
        brightness: Brightness.light,
        primary: brand,
        surface: cardBg,
        background: pageBg,
      ),
    );

    return base.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: sectionTitle,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: sectionTitle,
          fontSize: 19,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
        iconTheme: IconThemeData(color: sectionTitle),
      ),
      cardTheme: CardTheme(
        color: cardBg,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        shadowColor: cardShadow,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        selectedItemColor: brand,
        unselectedItemColor: textSecondary,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }

  /// 玻璃卡片用的柔和阴影，比旧版更轻，避免整页「一块块浮起来」。
  static List<BoxShadow> cardElevation(BuildContext context) => [
        BoxShadow(
          color: cardShadow.withOpacity(0.35),
          blurRadius: 14,
          offset: const Offset(0, 4),
        ),
      ];

  static BorderRadius radius18 = BorderRadius.circular(18);
  static BorderRadius radius14 = BorderRadius.circular(14);
  static BorderRadius radius10 = BorderRadius.circular(10);
}

/// 统一排版尺度。
///
/// 规则：
///   · 标题不再满屏 w700，统一 w600，字距收紧
///   · 所有文字带 height，行距稳定，不会在不同机型上忽宽忽窄
///   · 层级只有 6 档，页面里不再出现 9.5 / 10.5 / 11.5 / 12.5 / 13.5 / 14.5 / 15 / 17…
class AppText {
  AppText._();

  /// 页面主标题：发现 / 看一看 / 我
  static const display = TextStyle(
    fontSize: 19,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.4,
    color: AppTheme.sectionTitle,
    height: 1.25,
  );

  /// 分区标题：每日推荐 / 新书速递
  static const section = TextStyle(
    fontSize: 15.5,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
    color: AppTheme.sectionTitle,
    height: 1.3,
  );

  /// 卡片 / 书名主文字
  static const title = TextStyle(
    fontSize: 13.5,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    color: AppTheme.textPrimary,
    height: 1.35,
  );

  /// 正文
  static const body = TextStyle(
    fontSize: 12.5,
    fontWeight: FontWeight.w400,
    color: AppTheme.textPrimary,
    height: 1.5,
  );

  /// 副标题 / 作者 / 说明
  static const caption = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppTheme.textSecondary,
    height: 1.4,
  );

  /// 角标 / 进度数字 / 底栏文字
  static const micro = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppTheme.textSecondary,
    height: 1.3,
  );

  /// 链接式按钮：换一批 / 查看全部 / 编辑
  static const action = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppTheme.brand,
    height: 1.3,
  );
}
