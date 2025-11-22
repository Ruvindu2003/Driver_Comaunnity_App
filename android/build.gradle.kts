allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir = file("../../build")

subprojects {
    buildDir = File(newBuildDir, project.name)
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
