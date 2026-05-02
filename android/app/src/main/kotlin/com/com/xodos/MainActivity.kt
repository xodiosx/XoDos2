package com.com.xodos

import android.util.Log
import android.content.Intent
import android.os.Bundle // Required import
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {

    // Add this block to force software rendering
    override fun onCreate(savedInstanceState: Bundle?) {
        intent.putExtra("enable-software-rendering", true)
        super.onCreate(savedInstanceState)
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
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
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}
