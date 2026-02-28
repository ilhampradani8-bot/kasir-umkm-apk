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
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.3.2" apply false
    id("org.jetbrains.kotlin.android") version "2.0.0" apply false
}

include(":app")

val flutterSdkPath = System.getenv("FLUTTER_ROOT") ?: ""
if (flutterSdkPath.isNotEmpty()) {
    apply(from = "$flutterSdkPath/packages/flutter_tools/gradle/app_plugin_loader.gradle")
}
// PASTIKAN TIDAK ADA BLOK dependencyResolutionManagement DI SINI
