plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Instalação isolada para testes que apagam ou corrompem dados: com SERENA_APP_ID_SUFFIX=.seg o
// pacote vira br.com.serenacash.mobile.seg e convive com o app normal, sem tocar nos dados dele.
val appIdSuffix: String = System.getenv("SERENA_APP_ID_SUFFIX") ?: ""

android {
    namespace = "br.com.serenacash.mobile"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // Exigido por flutter_local_notifications (java.time no Android < 26).
        isCoreLibraryDesugaringEnabled = true
    }

    defaultConfig {
        applicationId = "br.com.serenacash.mobile"
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
        if (appIdSuffix.isNotBlank()) {
            applicationIdSuffix = appIdSuffix
        }
        manifestPlaceholders["appLabel"] =
            if (appIdSuffix.isNotBlank()) "SerenaCash teste" else "SerenaCash"
    }

    buildTypes {
        release {
            // Homologação interna: a variante release é assinada com a chave de debug desta máquina.
            // Serve para instalar e testar; não é a chave da loja e não vale para publicação. A chave
            // definitiva entra por um signingConfig próprio, fora do repositório, quando houver.
            signingConfig = signingConfigs.getByName("debug")
            // Regras do R8 do app, somadas às que o Flutter já aplica.
            proguardFiles("proguard-rules.pro")
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
