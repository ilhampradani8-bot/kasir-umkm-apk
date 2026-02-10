import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

// 1. Bagian membaca kunci dari brankas (key.properties)
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
        versionCode = 7 // Naikkan jadi 7 biar makin mantap!
        versionName = "1.0.6"
        
        multiDexEnabled = true
    }

    // 2. BAGIAN YANG TADI HILANG: Definisi tanda tangan
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
            // Sekarang robot sudah tahu 'release' itu yang mana
            signingConfig = signingConfigs.getByName("release")
            
            isMinifyEnabled = false 
            isShrinkResources = false
            
            ndk {
                abiFilters.addAll(listOf("armeabi-v7a", "arm64-v8a"))
            }
        }
    }
}

dependencies {
    implementation("androidx.multidex:multidex:2.0.1")
}
