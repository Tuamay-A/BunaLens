allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// ---------------------------------------------------------------------------
// Override compileSdk for all plugin submodules (e.g. tflite_flutter) so they
// compile against a modern Android SDK. This fixes "checkDebugAarMetadata"
// errors from plugins that still ship with compileSdk 31.
// ---------------------------------------------------------------------------
subprojects {
    afterEvaluate {
        if (project.hasProperty("android")) {
            val androidExt = project.extensions.findByName("android")
            if (androidExt != null) {
                try {
                    val setCompileSdk = androidExt.javaClass
                        .getMethod("setCompileSdk", Int::class.javaPrimitiveType)
                    val getCompileSdk = androidExt.javaClass
                        .getMethod("getCompileSdk")
                    val currentSdk = getCompileSdk.invoke(androidExt) as? Int
                    if (currentSdk != null && currentSdk < 36) {
                        setCompileSdk.invoke(androidExt, 36)
                    }
                } catch (e: Exception) {
                    // Ignore modules without compileSdk
                }
            }
        }
    }
}

// ---------------------------------------------------------------------------
// Redirect the build directory. Flutter 3.35+ expects the APK to end up at
// <project-root>/build/app/outputs/flutter-apk/. Two "../" are required.
// ---------------------------------------------------------------------------
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