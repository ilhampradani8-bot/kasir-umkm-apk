plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.ilham.pos.umkm"
    compileSdk = 35

    sourceSets {
        getByName("main").java.srcDirs("src/main/kotlin")
    }

    defaultConfig {
        applicationId = "com.ilham.pos.umkm"
        minSdk = 21 // Dukung Oppo A3s (Android 8.1)
        targetSdk = 35
        versionCode = 5 // Naikkan jadi 5!
        versionName = "1.0.4"
        
        multiDexEnabled = true
    }

    buildTypes {
        getByName("release") {
            isMinifyEnabled = false // MATIKAN: Agar sistem Oppo tidak bingung
            isShrinkResources = false // MATIKAN
            signingConfig = signingConfigs.getByName("release")
            
            ndk {
                abiFilters.addAll(listOf("armeabi-v7a", "arm64-v8a"))
            }
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("androidx.multidex:multidex:2.0.1")
}
