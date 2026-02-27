allprojects {
    repositories {
        google()
        mavenCentral()
        // --- GUDANG IKLAN APPODEAL & TIKTOK (PANGLE) ---
        maven { url = uri("https://artifactory.appodeal.com/appodeal") }
        maven { url = uri("https://artifact.bytedance.com/repository/pangle") }
    }
}

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
