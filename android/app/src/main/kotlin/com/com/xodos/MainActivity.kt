package com.com.xodos

import android.content.Intent
import android.os.Bundle
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Original channel (for android calls)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "android").setMethodCallHandler {
            call, result ->
            when (call.method) {
                "launchSignal9Page" -> {
                    startActivity(Intent(this@MainActivity, Signal9Activity::class.java))
                    result.success(0)
                }
                "getNativeLibraryPath" -> {
                    result.success(applicationInfo.nativeLibraryDir)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }

        // New channel for Vulkan driver loading (adrenotools)
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