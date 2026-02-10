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
    namespace = "com.ilham.pos.umkm"
    compileSdk = 35

    defaultConfig {
        applicationId = "com.ilham.pos.umkm"
        minSdk = 21 
        targetSdk = 35
        versionCode = 9 // Naikkan ke 9 agar fresh
        versionName = "1.0.8"
        
        multiDexEnabled = true
    }

    // --- BAGIAN PERBAIKAN ERROR JAVA ---
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }
    // ------------------------------------

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
}

dependencies {
    implementation("androidx.multidex:multidex:2.0.1")
}
