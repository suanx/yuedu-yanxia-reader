/// 阅读页顶栏的听书控件：播放/暂停切换 + 语速循环 + 加载旋转。
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yuedu/features/tts/tts_engine.dart';
import 'package:yuedu/features/tts/tts_notifier.dart';

class TtsPlayerButton extends ConsumerWidget {
  const TtsPlayerButton({super.key, required this.text});

  /// 整章正文，按下即从此处开始朗读
  final String text;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(ttsStateProvider).asData?.value;
    final ctrl = ref.read(ttsControllerProvider);
    final rate = ref.watch(ttsRateProvider);
    final isSpeaking = state == TtsEngineState.speaking;
    final isBusy = state == TtsEngineState.initializing;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: isSpeaking ? '暂停听书' : '开始听书',
          onPressed: isBusy
              ? null
              : () => isSpeaking ? ctrl.pause() : ctrl.play(text),
          icon: isBusy
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(
                  isSpeaking
                      ? Icons.pause_circle_outline_rounded
                      : Icons.headphones_rounded,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
        ),
        TextButton(
          style: TextButton.styleFrom(
            minimumSize: const Size(38, 32),
            padding: EdgeInsets.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          onPressed: ctrl.cycleRate,
          child: Text(
            ctrl.rateLabel,
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ),
      ],
    );
  }
}
