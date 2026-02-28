import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.example.kalkulator_bisnis_umkm" 
    compileSdk = 35 // <--- GANTI JADI 35

    // Force latest Build Tools version to handle 16KB memory alignment
    buildToolsVersion = "35.0.0"

    defaultConfig {
        applicationId = "com.ilham.pos.umkm" // App ID
        minSdk = 23 // Minimum SDK
        targetSdk = 35 // Required Play Store target SDK
        versionCode = 23 // Increment version code to bypass rejection
        versionName = "1.2.1" // Increment version name
        multiDexEnabled = true // Enable multidex
    }

    packagingOptions {
        exclude("META-INF/AL2.0")
        exclude("META-INF/LGPL2.1")
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String?
            keyPassword = keystoreProperties["keyPassword"] as String?
            storeFile = keystoreProperties["storeFile"]?.let { file(it) }
            storePassword = keystoreProperties["storePassword"] as String?
        }
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = false
            isShrinkResources = false
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

// INI KUNCINYA AGAR PLUGIN BISA MASUK
flutter {
    source = "../.."
}

dependencies {
    implementation("androidx.core:core-ktx:1.12.0")
    implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.6.2")
    implementation("androidx.window:window:1.0.0")
    implementation("androidx.window:window-java:1.0.0")
    implementation("androidx.multidex:multidex:2.0.1")

    // BAGIAN MANUAL FLUTTER.JAR SUDAH SAYA HAPUS AGAR TIDAK DUPLIKAT
}
