
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

dependencyResolutionManagement {
    repositoriesMode.set(
        RepositoriesMode.PREFER_SETTINGS
    )

    val flutterStorageUrl =
        System.getenv("FLUTTER_STORAGE_BASE_URL")
            ?: "https://storage.googleapis.com"

    repositories {
        google()
        mavenCentral()

        // Required for Flutter engine dependencies
        maven {
            url = uri(
                "$flutterStorageUrl/download.flutter.io"
            )
        }

        // PayHere Android SDK
        maven {
            url = uri(
                "https://repo.repsy.io/mvn/payhere/payhere-mobilesdk-android/"
            )
        }

        maven {
            url = uri("https://jitpack.io")
        }

        mavenLocal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"

    id("com.android.application") version "9.1.0" apply false

    id("com.google.gms.google-services") version "4.4.4" apply false

    id("org.jetbrains.kotlin.android") version "2.4.0" apply false
}

include(":app")
