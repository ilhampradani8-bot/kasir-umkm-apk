pluginManagement {
    val flutterSdkPath = System.getenv("FLUTTER_ROOT") ?: ""
    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id "dev.flutter.flutter-plugin-loader" version "1.0.0"
    id "com.android.application" version "7.3.0" apply false
    // Update versi Kotlin ke 1.9.22 untuk Appodeal
    id "org.jetbrains.kotlin.android" version "1.9.22" apply false
}
include(":app")

// Tambahan agar plugin share_plus, path_provider, dll terbaca
val flutterSdkPath = System.getenv("FLUTTER_ROOT") ?: ""
if (flutterSdkPath.isNotEmpty()) {
    apply(from = "$flutterSdkPath/packages/flutter_tools/gradle/app_plugin_loader.gradle")
}
