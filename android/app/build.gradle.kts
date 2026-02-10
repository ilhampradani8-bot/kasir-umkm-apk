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
        versionCode = 8 // Naikkan jadi 8
        versionName = "1.0.7"
        
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
            
            // BAGIAN NDK ABIFILTERS SUDAH DIHAPUS UNTUK MENGHINDARI BENTROK
        }
    }
}

dependencies {
    implementation("androidx.multidex:multidex:2.0.1")
}
