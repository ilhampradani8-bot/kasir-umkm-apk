plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.ilham.pos.umkm"
    compileSdk = 35

    defaultConfig {
        applicationId = "com.ilham.pos.umkm"
        minSdk = 21 
        targetSdk = 35
        versionCode = 6 // Naikkan jadi 6
        versionName = "1.0.5"
        
        multiDexEnabled = true
    }

    buildTypes {
        getByName("release") {
            isMinifyEnabled = false 
            isShrinkResources = false
            signingConfig = signingConfigs.getByName("release")
            
            ndk {
                abiFilters.addAll(listOf("armeabi-v7a", "arm64-v8a"))
            }
        }
    }
}

dependencies {
    implementation("androidx.multidex:multidex:2.0.1")
}
