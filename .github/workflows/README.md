# 构建说明

- `android_build.yml`：push / PR / 手动触发都会在 GitHub 托管的 Ubuntu 上
  安装 Flutter 3.24.5 并构建 APK，产物在每次运行的 **Artifacts → yuedu-yanxia**。
- `android/gradlew`、`gradle-wrapper.jar` 是二进制文件，不入库；流水线会用
  `flutter create` 从 Flutter SDK 生成官方骨架再补进去，本地跑请先执行
  `flutter create --platforms=android .` 一次。
- release 构建使用 debug 签名，APK 可直接安装。正式上架时把 keystore 配进
  仓库 Secrets（KEYSTORE_BASE64 / KEYSTORE_PASSWORD / KEY_ALIAS / KEY_PASSWORD），
  流水线会用 apksigner 自动重签。
