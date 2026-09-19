
import java.util.Properties
        import java.io.FileInputStream

        plugins {
            id("com.android.application")
            id("com.google.gms.google-services")
            id("kotlin-android")
            id("dev.flutter.flutter-gradle-plugin")
        }

        kotlin {
            jvmToolchain(17)
        }

// Load keystore properties
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()

if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

        android {
            namespace = "com.main.kaf8"
            compileSdk = 36
            ndkVersion = flutter.ndkVersion

            compileOptions {
                sourceCompatibility = JavaVersion.VERSION_17
                targetCompatibility = JavaVersion.VERSION_17
                isCoreLibraryDesugaringEnabled = true
            }


            defaultConfig {
                applicationId = "com.main.kaf8"
                minSdk = flutter.minSdkVersion
                targetSdk = 35
                versionCode = flutter.versionCode
                versionName = flutter.versionName
                multiDexEnabled = true
            }

            buildTypes {
                release {
                    signingConfig = signingConfigs.getByName("debug")
                    isMinifyEnabled = false
                    isShrinkResources = false
                }
            }
        }
flutter {
    source = "../.."
}

dependencies {
    // Import the Firebase BoM
//    implementation(platform("com.google.firebase:firebase-bom:33.7.0"))
//
//    // Firebase Authentication
//    implementation("com.google.firebase:firebase-auth")
//
//    // Firebase Firestore
//    implementation("com.google.firebase:firebase-firestore")

    // Google Play Services Auth (required for phone auth)
//    implementation("com.google.android.gms:play-services-auth:21.2.0")
//    implementation("com.google.android.gms:play-services-auth-api-phone:18.1.0")

    // Multidex support
    implementation("androidx.multidex:multidex:2.0.1")

    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")

}