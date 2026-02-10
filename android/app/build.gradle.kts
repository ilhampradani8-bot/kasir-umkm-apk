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
    compileSdk = 34

    defaultConfig {
        applicationId = "com.ilham.pos.umkm"
        minSdk = 21 
        targetSdk = 34
        versionCode = 14 // Naikkan ke 14
        versionName = "1.1.3"
        multiDexEnabled = true
    }

    // --- TAMENG ANTI-DUPLIKAT (SOLUSI AGAR TIDAK ERROR 2 FILES FOUND) ---
    packaging {
        jniLibs {
            useLegacyPackaging = true
            pickFirsts += "**/libflutter.so"
        }
        resources {
            excludes += "/META-INF/{AL2.0,LGPL2.1}"
        }
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
    // --- JURUS PAKSA (AGAR KOTLIN TIDAK BUTA LAGI) ---
    implementation(files("${System.getenv("FLUTTER_ROOT")}/bin/cache/artifacts/engine/android-arm/flutter.jar"))
}
