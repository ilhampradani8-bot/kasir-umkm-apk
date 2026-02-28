

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.set(newBuildDir)

subprojects {
    project.layout.buildDirectory.set(newBuildDir.dir(project.name))
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
allprojects {
    repositories {
        google()
        mavenCentral()
        // Repositori Wajib Flutter
        maven { url = uri("https://storage.googleapis.com/download.flutter.io") }
        // Repositori Wajib Appodeal & Iklan Lainnya
        maven { url = uri("https://artifactory.appodeal.com/appodeal") }
        maven { url = uri("https://artifact.bytedance.com/repository/pangle") }
        maven { url = uri("https://android-sdk.is.com/") }
        maven { url = uri("https://jitpack.io") }
    }
}
