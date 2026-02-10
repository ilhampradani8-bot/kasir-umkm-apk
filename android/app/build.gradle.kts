import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin") // Pastikan ini ada!
}

val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    // Namespace HARUS SAMA dengan nama folder di error tadi
    namespace = "com.example.kalkulator_bisnis_umkm" 
    compileSdk = 34

    defaultConfig {
        applicationId = "com.ilham.pos.umkm"
        minSdk = 21 
        targetSdk = 34
        versionCode = 12 // Naikkan ke 12
        versionName = "1.1.1"
        multiDexEnabled = true
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

dependencies {
    implementation("androidx.multidex:multidex:2.0.1")
    // JURUS PAKSA: Tambahkan ini jika Kotlin masih buta
    implementation(files("${System.getenv("FLUTTER_ROOT")}/bin/cache/artifacts/engine/android-arm/flutter.jar"))
}
