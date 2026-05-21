package com.xodos

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Existing channel for other calls
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "android").setMethodCallHandler {
            call, result ->
            when (call.method) {
                "launchSignal9Page" -> {
                    startActivity(Intent(this, Signal9Activity::class.java))
                    result.success(0)
                }
                "getNativeLibraryPath" -> {
                    result.success(getApplicationInfo().nativeLibraryDir)
                }
                else -> result.notImplemented()
            }
        }

        // NEW channel for driver loading
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.xodos/vulkan_loader").setMethodCallHandler {
            call, result ->
            when (call.method) {
                "loadCustomDriver" -> {
                    val driverDir = call.argument<String>("driverDir") ?: ""
                    val driverName = call.argument<String>("driverName") ?: ""
                    val hooksDir = call.argument<String>("hooksDir") ?: ""
                    val success = VulkanLoader.nativeLoadCustomDriver(driverDir, driverName, hooksDir)
                    result.success(success)
                }
                "loadSystemDriver" -> {
                    result.success(VulkanLoader.nativeLoadSystemDriver())
                }
                else -> result.notImplemented()
            }
        }
    }
}