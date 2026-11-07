# 檐下 · Yanxia Reader

Flutter 安卓阅读 App：发现 / 书架 / 横排·竖排阅读 / 系统 TTS 听书跟读。

## 出包（不用电脑）

1. 打开仓库 **Actions → Android 构建 → 最新一次运行**
2. 下载 **Artifacts → yuedu-yanxia**（`yuedu-yanxia.apk`）
3. 手机上点开 APK，允许「安装未知来源应用」即可装上

APK 带 debug 签名，可直接安装，无需额外 keystore。

## 本地开发

```bash
flutter create --platforms=android .   # 首次补全 gradlew / wrapper jar
flutter pub get
flutter run -d android
```

要求 Flutter 3.24.5 / Dart 3.5+，最低 Android SDK 21。
