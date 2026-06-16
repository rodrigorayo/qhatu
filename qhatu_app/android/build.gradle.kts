allprojects {
    repositories {
        google()
        mavenCentral()
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

subprojects {
    val configureProject = { prj: Project ->
        if (prj.plugins.hasPlugin("com.android.library") || prj.plugins.hasPlugin("com.android.application")) {
            val android = prj.extensions.findByName("android")
            if (android != null) {
                try {
                    // 1. Configurar namespace si es nulo
                    val getNamespace = android.javaClass.getMethod("getNamespace")
                    val setNamespace = android.javaClass.getMethod("setNamespace", String::class.java)
                    if (getNamespace.invoke(android) == null) {
                        val defaultNamespace = if (prj.group.toString().isNotEmpty()) {
                            prj.group.toString()
                        } else {
                            "com.qhatu.${prj.name.replace("-", "_").replace(".", "_")}"
                        }
                        setNamespace.invoke(android, defaultNamespace)
                        logger.quiet("Auto-configured namespace: $defaultNamespace for subproject: ${prj.name}")
                    }
                } catch (e: Exception) {
                    // Ignorar
                }

                try {
                    // 2. Forzar compileSdkVersion a 34 para evitar incompatibilidad de metadatos AAR
                    val setCompileSdkVersion = android.javaClass.getMethod("setCompileSdkVersion", Int::class.javaPrimitiveType)
                    setCompileSdkVersion.invoke(android, 34)
                    logger.quiet("Auto-configured compileSdkVersion to 34 for subproject: ${prj.name}")
                } catch (e: Exception) {
                    try {
                        val setCompileSdkVersionInt = android.javaClass.getMethod("setCompileSdkVersion", Integer::class.java)
                        setCompileSdkVersionInt.invoke(android, 34)
                        logger.quiet("Auto-configured compileSdkVersion (Integer) to 34 for subproject: ${prj.name}")
                    } catch (e2: Exception) {
                        // Ignorar
                    }
                }
            }
        }
    }

    if (project.state.executed) {
        configureProject(project)
    } else {
        project.afterEvaluate {
            configureProject(project)
        }
    }
}

