pluginManagement {
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            val localPropertiesFile = java.io.File("local.properties")
            if (localPropertiesFile.exists()) {
                java.io.FileInputStream(localPropertiesFile).use { inputStream ->
                    properties.load(inputStream)
                }
            }
            val flutterSdkPath = properties.getProperty("flutter.sdk")
                ?: System.getenv("FLUTTER_ROOT")
            require(flutterSdkPath != null) { "flutter.sdk not set in local.properties nor FLUTTER_ROOT environment variable" }
            flutterSdkPath
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        maven { url = uri("https://developer.huawei.com/repo/") }
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.4.0" apply false
    id("org.jetbrains.kotlin.android") version "1.9.24" apply false
}

include(":app")
