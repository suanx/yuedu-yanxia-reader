import 'package:flutter/material.dart';
import 'package:yuedu/core/theme/app_theme.dart';

/// 阅读页底部进度条：左「68%」+ 滑块 + 右「142/208」
class ReadingProgressBar extends StatelessWidget {
  const ReadingProgressBar({
    super.key,
    required this.progress,
    required this.page,
    required this.total,
    this.onChanged,
  });

  final double progress;
  final int page;
  final int total;
  final ValueChanged<double>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 4,
            // 用内置圆角滑块：自定义 SliderComponentShape.paint 的
            // textScaleFactor / textScaler 参数在 Flutter 版本间有变更，
            // 内置 shape 可避免 @override 签名不匹配导致编译失败。
            thumbShape: const RoundSliderThumbShape(
              enabledThumbRadius: 8,
              disabledThumbRadius: 6,
              pressedElevation: 2,
            ),
            overlayShape: SliderComponentShape.noOverlay,
            activeTrackColor: AppTheme.brand,
            inactiveTrackColor: Colors.white.withOpacity(0.75),
            valueIndicatorColor: AppTheme.brand,
          ),
          child: Slider(
            value: progress.clamp(0.0, 1.0),
            onChanged: onChanged ?? (_) {},
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 0, 22, 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(progress * 100).round()}%',
                style: const TextStyle(
                  color: AppTheme.brand,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '$page/$total',
                style: const TextStyle(
                  color: AppTheme.inkSoft,
                  fontSize: 12.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
