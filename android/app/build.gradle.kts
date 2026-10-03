plugins {
    id("com.android.application")

    // Google Services / Firebase
    id("com.google.gms.google-services")

    // Flutter Gradle Plugin must be applied after Android plugin
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.oneclick"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.example.oneclick"

        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion

        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Firebase Bill of Materials
    implementation(platform("com.google.firebase:firebase-bom:34.19.0"))
}