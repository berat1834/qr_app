plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

<<<<<<< HEAD
import java.util.Properties
import java.io.FileInputStream

// Load key.properties
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
<<<<<<< HEAD:android/temp_project/android/app/build.gradle.kts
    namespace = "com.example.temp_project"
    compileSdk = flutter.compileSdkVersion
=======
    namespace = "com.qrscanner.professional"
    compileSdk = 36
>>>>>>> 92e7da0 (Initial standalone deploy-ready version):android/app/build.gradle.kts
=======
android {
    namespace = "com.example.temp_project"
    compileSdk = flutter.compileSdkVersion
>>>>>>> 9cc3d20 (İlk proje yüklemesi)
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

<<<<<<< HEAD
    signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists()) {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    defaultConfig {
<<<<<<< HEAD:android/temp_project/android/app/build.gradle.kts
=======
    defaultConfig {
>>>>>>> 9cc3d20 (İlk proje yüklemesi)
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.temp_project"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
<<<<<<< HEAD
=======
        applicationId = "com.qrscanner.professional"
        minSdk = flutter.minSdkVersion  // Android 5.0 - 99%+ device coverage
        targetSdk = 36  // Android 15 - Play Store requirement
        versionCode = 1
        versionName = "1.0.0"
        multiDexEnabled = true
>>>>>>> 92e7da0 (Initial standalone deploy-ready version):android/app/build.gradle.kts
=======
>>>>>>> 9cc3d20 (İlk proje yüklemesi)
    }

    buildTypes {
        release {
<<<<<<< HEAD
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            signingConfig = signingConfigs.getByName("release")
=======
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
>>>>>>> 9cc3d20 (İlk proje yüklemesi)
        }
    }
}

flutter {
    source = "../.."
}
