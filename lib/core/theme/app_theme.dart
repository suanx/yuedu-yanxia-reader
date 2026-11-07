import 'package:flutter/material.dart';

/// 对齐设计稿：冷白卡片底 + 克莱因蓝点缀 + 暖黄阅读纸
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
        backgroundColor: pageBg,
        foregroundColor: sectionTitle,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: sectionTitle,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
        iconTheme: IconThemeData(color: sectionTitle),
      ),
      cardTheme: CardThemeData(
        color: cardBg,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        shadowColor: cardShadow,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: brand,
        unselectedItemColor: textSecondary,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }

  static List<BoxShadow> cardElevation(BuildContext context) => [
        BoxShadow(
          color: cardShadow.withOpacity(0.55),
          blurRadius: 18,
          offset: const Offset(0, 6),
        ),
      ];

  static BorderRadius radius18 = BorderRadius.circular(18);
  static BorderRadius radius14 = BorderRadius.circular(14);
  static BorderRadius radius10 = BorderRadius.circular(10);
}
