allprojects {
    repositories {
        google()
        mavenCentral()
    }
    // androidx.core 1.19.0 menuntut AGP 9.1.0+, sedangkan proyek ini memakai AGP 8.11.1.
    // Kunci ke versi yang kompatibel agar build release tetap bisa dijalankan.
    configurations.all {
        resolutionStrategy {
            force("androidx.core:core:1.16.0")
            force("androidx.core:core-ktx:1.16.0")
        }
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
