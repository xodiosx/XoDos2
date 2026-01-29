package com.com.xodos

import android.content.Intent
import android.os.Bundle
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "android"
    private var channel: MethodChannel? = null

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        channel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        )

        channel?.setMethodCallHandler { call, result ->
            when (call.method) {

                "launchSignal9Page" -> {
                    startActivity(Intent(this, Signal9Activity::class.java))
                    result.success(0)
                }

                "getNativeLibraryPath" -> {
                    result.success(applicationInfo.nativeLibraryDir)
                }

                else -> result.notImplemented()
            }
        }
    }

    // ✅ APP GOES BACKGROUND
    override fun onPause() {
        super.onPause()
        channel?.invokeMethod("appBackground", null)
    }

    // ✅ APP COMES FOREGROUND
    override fun onResume() {
        super.onResume()
        channel?.invokeMethod("appForeground", null)
    }
}