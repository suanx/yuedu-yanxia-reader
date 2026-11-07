import 'package:flutter/material.dart';

abstract final class AppConstants {
  AppConstants._();

  static const double cardRadius = 18.0;
  static const double coverRadius = 12.0;
  static const double pagePadding = 20.0;
  static const double gridGap = 14.0;

  static const Duration animFast = Duration(milliseconds: 220);
  static const Duration animMed = Duration(milliseconds: 360);

  /// 阅读页默认字号档位
  static const List<double> fontSizeSteps = [15, 17, 19, 21, 23];

  /// 仿真翻页/滑动页边距
  static const double readingHorizontalPad = 22.0;
  static const double readingVerticalPad = 26.0;
}

/// 书架为空 / 封面缺失时的柔和渐变，替代真实图片
final List<List<Color>> coverGradients = [
  [const Color(0xFF6A8CFF), const Color(0xFF3D5BDB)],
  [const Color(0xFFF6A8B4), const Color(0xFFE8798C)],
  [const Color(0xFF7BD88F), const Color(0xFF3FA85A)],
  [const Color(0xFFFFC36B), const Color(0xFFF7931E)],
  [const Color(0xFF9B8BF5), const Color(0xFF6A5BD0)],
  [const Color(0xFF6CD3E6), const Color(0xFF2FA8C4)],
  [const Color(0xFFF28B8B), const Color(0xFFC2566B)],
  [const Color(0xFFB6C28A), const Color(0xFF8A9A5B)],
  [const Color(0xFF8A9BC4), const Color(0xFF5A6FA0)],
];
