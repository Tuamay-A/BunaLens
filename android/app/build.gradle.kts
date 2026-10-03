plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.bunalens.app"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.bunalens.app"
        // minSdk 21 required for:
        //   • Supabase Flutter (uses modern TLS APIs)
        //   • sqlite3_flutter_libs (native SQLite)
        //   • flutter_secure_storage (Android Keystore)
        // Infinix Smart 8 ships Android 13 (API 33) — well above this.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

// ---------------------------------------------------------------------------
// Workaround: Flutter expects the APK at build/app/outputs/flutter-apk/
// but newer AGP versions place it at android/app/build/outputs/apk/debug/.
// This task copies the APK to the location Flutter is looking for.
// ---------------------------------------------------------------------------
tasks.register<Copy>("copyDebugApk") {
    from(layout.buildDirectory.dir("outputs/apk/debug"))
    into(rootProject.layout.buildDirectory.dir("app/outputs/flutter-apk"))
    include("*.apk")
    rename { "app-debug.apk" }
}

tasks.register<Copy>("copyReleaseApk") {
    from(layout.buildDirectory.dir("outputs/apk/release"))
    into(rootProject.layout.buildDirectory.dir("app/outputs/flutter-apk"))
    include("*.apk")
    rename { "app-release.apk" }
}

// Hook the copy tasks to run automatically after assemble tasks finish.
tasks.matching { it.name == "assembleDebug" }.configureEach {
    finalizedBy("copyDebugApk")
}

tasks.matching { it.name == "assembleRelease" }.configureEach {
    finalizedBy("copyReleaseApk")
}
