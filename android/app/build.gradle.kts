plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.yanxia.reader"
    compileSdk = flutter.compileSdkVersion

    defaultConfig {
        applicationId = "com.yanxia.reader"
        minSdk = 21
        targetSdk = 34
        versionCode = flutter.versionCode ?: 1
        versionName = flutter.versionName ?: "1.0.0"
    }

    // 用 debug 签名构建 release：产出的 APK 可直接安装到手机，
    // 不依赖用户额外配置 keystore。正式发布时由 CI 用 secrets 里的
    // keystore 通过 apksigner 重签（见 .github/workflows/android_build.yml）。
    val debugSigning = signingConfigs.getByName("debug")

    buildTypes {
        release {
            signingConfig = debugSigning
            // 先保证能出包；混淆留到接真内容/第三方 SDK 时再开
            isMinifyEnabled = false
            isShrinkResources = false
        }
        debug {
            isMinifyEnabled = false
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }
}

flutter {
    source = "../.."
}
