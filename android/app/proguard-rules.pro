# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class dev.flutter.** { *; }

# 数据模型（json_serializable / 手写 fromJson）
-keepclassmembers class * {
    <init>(...);
    public ** fromJson(...);
    public ** toJson();
}
-dontwarn io.flutter.**
