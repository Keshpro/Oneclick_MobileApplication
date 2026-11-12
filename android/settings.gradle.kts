
pluginManagement {
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            file("local.properties").inputStream().use {
                properties.load(it)
            }

            val flutterSdkPath =
                properties.getProperty("flutter.sdk")

            require(flutterSdkPath != null) {
                "flutter.sdk not set in local.properties"
            }

            flutterSdkPath
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

// PayHere Android SDK repository
dependencyResolutionManagement {
    repositoriesMode.set(
        RepositoriesMode.PREFER_SETTINGS
    )

    repositories {
        google()
        mavenCentral()
        mavenLocal()

        maven {
            url = uri(
                "https://repo.repsy.io/mvn/payhere/payhere-mobilesdk-android/"
            )
        }

        maven {
            url = uri("https://jitpack.io")
        }
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"

    id("com.android.application") version "9.1.0" apply false

    // Firebase / Google Services
    id("com.google.gms.google-services") version "4.4.4" apply false

    id("org.jetbrains.kotlin.android") version "2.4.0" apply false
}

include(":app")
