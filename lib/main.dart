import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yuedu/core/router/app_router.dart';
import 'package:yuedu/core/theme/app_theme.dart';
import 'package:yuedu/features/tts/tts.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: YueduApp()));
}

class YueduApp extends ConsumerStatefulWidget {
  const YueduApp({super.key});

  @override
  ConsumerState<YueduApp> createState() => _YueduAppState();
}

class _YueduAppState extends ConsumerState<YueduApp> {
  @override
  void initState() {
    super.initState();
    // 用 App 自己的 ProviderContainer 预热听书引擎：
    // 之前用独立 container 预热是无效的，阅读页拿到的是另一个实例。
    Future.microtask(() async {
      try {
        await ref.read(ttsEngineProvider).init();
      } catch (_) {
        // 模拟器 / 无中文语音引擎时静默降级，不阻塞 UI
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: '檐下',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routerConfig: router,
      builder: (context, child) {
        // 全局字体缩放锁定，避免系统大字号把卡片撑破
        final scaler = MediaQuery.textScalerOf(context);
        final factor = (scaler.scale(14) / 14).clamp(0.9, 1.15);
        return MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(factor)),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
