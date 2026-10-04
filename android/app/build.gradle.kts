plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.nurturebaby.nurture"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.nurturebaby.nurture"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            // Release signing credentials come from environment variables so
            // secrets never live in the repo.
            //   KEYSTORE_PATH      - path to nurture-release.keystore
            //                        (falls back to CM_KEYSTORE_PATH set by
            //                        Codemagic code signing, then to the local file)
            //   KEYSTORE_PASSWORD  - keystore password (or CM_KEYSTORE_PASSWORD)
            //   KEY_ALIAS          - key alias, "nurture" (or CM_KEY_ALIAS)
            //   KEY_PASSWORD       - key password (or CM_KEY_PASSWORD)
            val keystorePath = System.getenv("KEYSTORE_PATH")
                ?: System.getenv("CM_KEYSTORE_PATH")
                ?: "nurture-release.keystore"
            storeFile = file(keystorePath)
            storePassword = System.getenv("KEYSTORE_PASSWORD")
                ?: System.getenv("CM_KEYSTORE_PASSWORD")
            keyAlias = System.getenv("KEY_ALIAS")
                ?: System.getenv("CM_KEY_ALIAS")
            keyPassword = System.getenv("KEY_PASSWORD")
                ?: System.getenv("CM_KEY_PASSWORD")
        }
    }

    buildTypes {
        release {
            // Use the release signing config when credentials are present
            // (Codemagic). Fall back to debug keys for local `flutter run --release`.
            signingConfig = if (System.getenv("KEYSTORE_PASSWORD") != null ||
                System.getenv("CM_KEYSTORE_PASSWORD") != null) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
            // Keep R8/minification off for the first store release to avoid
            // shrinking surprises; can be enabled later once verified.
            isMinifyEnabled = false
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
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
