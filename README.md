# 阅读 · Yuedu (Flutter / Android)

对齐设计稿三屏：发现（搜索 + 每日推荐横滑大卡 + 新书速递横滑小卡）、
书架（3 列网格 + 编辑多选 + 进度条）、阅读页（暖黄纸 + 章节标题 + 正文 + 68% 进度条 / 页码）。
当前为**可运行骨架**，书籍/章节均为假数据，接接口只需替换 `lib/data/repositories/mock_library.dart`。

## 本地跑起来

```bash
flutter pub get
flutter run -d android          # 真机 / 模拟器
flutter test                     # Widget 测试
flutter analyze                  # 静态检查
```

> 字体：默认用系统衬线回退。把 `.ttf` 放进 `assets/fonts/` 并在
> `pubspec.yaml` 的 `fonts` 段启用 `SerifReading` 即可获得截图里的纸感正文。
> 封面：放 9 张 3:4 图到 `assets/covers/`，命名为 `cover_01.png …`，
> 并在 `Book` 里填 `coverAsset`；缺图会自动用渐变色块 + 书本图标兜底。

## 工程结构

```
lib/
  core/       主题(AppTheme)、常量、路由、Provider 容器
  data/       模型(Book/Chapter) + 假数据 + 阅读偏好状态
  features/   discover / bookshelf / reading / feed / profile
  widgets/    BookCover / FeaturedCard / BookshelfTile / ReadingProgressBar
android/     Gradle 8.7 + AGP 8.1，签名由 CI 密钥注入
.github/workflows/android-release.yml
```

## 打包 / 签名

- Debug：直接 `flutter build apk --debug`，用 debug 签名。
- Release：`flutter build apk --release`，默认读取环境变量签名；
  本地未配置密钥时会**自动回退到 debug 签名**，不会报错中断。

### CI 密钥（GitHub Secrets）

| Secret | 说明 |
|---|---|
| `KEYSTORE_BASE64` | `base64 -w0 your.keystore \| pbcopy`，整个文件编码 |
| `KEYSTORE_PASSWORD` | keystore 密码 |
| `KEY_ALIAS` | 别名 |
| `KEY_PASSWORD` | 别名私钥密码 |

Workflow 会在 release 构建前把 keystore 还原到 `android/app/upload.keystore`。
**推送打正式包时会在 workflow 里停下来等你确认这些 secret 已填好。**

## 待接入（标了 TODO 的地方）

1. 书架卡片 `onTap` → `context.push('/read?title=...')`
2. 搜索框提交 → 搜索页 / 接口
3. 阅读页真实分页：按文本高度切页（长章节别整段塞一个 Text）
4. 听书：`flutter_tts` / Sherpa-ONNX 端侧引擎，见 `ProfilePage` 入口占位

## 许可

代码 MIT。书籍内容与封面图请自行确认授权。
