package com.com.xodos

import android.util.Log
import android.content.Intent
import android.os.Bundle
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {

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
        "showCrashScreen" -> {
            val stackTrace = call.argument<String>("stackTrace") ?: "Unknown error"
            val intent = Intent(this, CrashActivity::class.java).apply {
                putExtra("EXTRA_STACK_TRACE", stackTrace)
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK)
            }
            startActivity(intent)
            result.success(0)
        }
        else -> result.notImplemented()
    }
}
        
    }

}
