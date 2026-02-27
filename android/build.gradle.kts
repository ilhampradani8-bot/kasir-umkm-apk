allprojects {
    repositories {
        google()
        mavenCentral()
        // --- GUDANG IKLAN APPODEAL & TIKTOK (PANGLE) ---
        maven("https://artifactory.appodeal.com/appodeal")
        maven("https://artifact.bytedance.com/repository/pangle")
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
