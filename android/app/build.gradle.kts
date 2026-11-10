plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.mobile_project_doa_ibu"
    compileSdk = 37
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    signingConfigs {
        create("demo") {
            // Keystore demo agar SHA-1 build stabil dan bisa didaftarkan sebagai
            // Android OAuth client. Ganti dengan keystore rilis resmi sebelum publikasi.
            storeFile = file("doaibu-demo.jks")
            storePassword = "doaibu2026"
            keyAlias = "doaibu"
            keyPassword = "doaibu2026"
        }
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.mobile_project_doa_ibu"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("demo")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Diperlukan flutter_local_notifications 23 (API notifikasi baru).
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
}
