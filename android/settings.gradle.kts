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
    // Load standard flutter plugin
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    // Upgrade Android Gradle Plugin to 8.5.2 for 16KB page size support
    id("com.android.application") version "8.5.2" apply false
    // Keep Kotlin at 2.0.0
    id("org.jetbrains.kotlin.android") version "2.0.0" apply false
}

include(":app")

val flutterSdkPath = System.getenv("FLUTTER_ROOT") ?: ""
if (flutterSdkPath.isNotEmpty()) {
    apply(from = "$flutterSdkPath/packages/flutter_tools/gradle/app_plugin_loader.gradle")
}
// PASTIKAN TIDAK ADA BLOK dependencyResolutionManagement DI SINI
