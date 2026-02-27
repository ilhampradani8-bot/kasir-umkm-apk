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
    id("com.android.application") version "7.3.0" apply false
    id("org.jetbrains.kotlin.android") version "2.0.0" apply false
}

include(":app")

// Tambahan agar plugin share_plus, path_provider, dll terbaca
val flutterSdkPath = System.getenv("FLUTTER_ROOT") ?: ""
if (flutterSdkPath.isNotEmpty()) {
    apply(from = "$flutterSdkPath/packages/flutter_tools/gradle/app_plugin_loader.gradle")
}

// --- BLOK BARU UNTUK MENGUNDUH SDK IKLAN (PANGLE & APPODEAL) ---
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.PREFER_PROJECT)
    repositories {
        google()
        mavenCentral()
        maven { url = uri("https://artifactory.appodeal.com/appodeal") }
        maven { url = uri("https://artifact.bytedance.com/repository/pangle") }
    }
}
