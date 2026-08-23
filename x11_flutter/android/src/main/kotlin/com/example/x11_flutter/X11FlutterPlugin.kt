package com.example.x11_flutter

import android.content.Intent
import android.os.Build
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class X11FlutterPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {

    private lateinit var channel: MethodChannel
    private var activity: android.app.Activity? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "x11_flutter")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
          "launchXServer" -> {
    try {
        val context = activity?.applicationContext
            ?: throw IllegalStateException("No activity context available")

        val tmpdir = call.argument<String>("tmpdir")
        val xkb = call.argument<String>("xkb")
        val serverArgs = call.argument<List<String>>("serverArgs")

        val intent = Intent(context, com.termux.x11.X11ServerService::class.java)
        if (tmpdir != null) intent.putExtra("tmpdir", tmpdir)
        if (xkb != null) intent.putExtra("xkb", xkb)
        if (serverArgs != null) {
            intent.putExtra("serverArgs", serverArgs.toTypedArray())
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            context.startForegroundService(intent)
        } else {
            context.startService(intent)
        }

        Log.i("X11Flutter", "X11ServerService started with args")
        result.success(0)
    } catch (e: Exception) {
        result.error("LAUNCH_XSERVER_FAILED", "Failed to start X server: ${e.message}", e.stackTraceToString())
    }
}
            "launchX11PrefsPage" -> {
                try {
                    activity?.let {
                        val intent = Intent(it, com.termux.x11.LoriePreferences::class.java)
                        it.startActivity(intent)
                        result.success(0)
                    } ?: run {
                        result.error("NO_ACTIVITY", "No activity available to launch preferences", null)
                    }
                } catch (e: Exception) {
                    result.error("LAUNCH_PREFS_FAILED", "Failed to launch preferences: ${e.message}", e.stackTraceToString())
                }
            }
            "launchX11Page" -> {
                try {
                    activity?.let {
                        val intent = Intent(it, com.termux.x11.MainActivity::class.java)
                        it.startActivity(intent)
                        result.success(0)
                    } ?: run {
                        result.error("NO_ACTIVITY", "No activity available to launch X11 page", null)
                    }
                } catch (e: Exception) {
                    result.error("LAUNCH_X11_PAGE_FAILED", "Failed to launch X11 page: ${e.message}", e.stackTraceToString())
                }
            }
            "setScale" -> {
                try {
                    val scale = call.argument<Double>("scale")
                    if (scale == null) {
                        result.error("INVALID_ARGUMENTS", "scale argument is required", null)
                        return
                    }
                    val intent = Intent("com.termux.x11.CHANGE_PREFERENCE").apply {
                        putExtra("tc_displayScale", scale.toString())
                        setPackage(activity!!.packageName)
                    }
                    activity!!.sendBroadcast(intent)
                    result.success(0)
                } catch (e: Exception) {
                    result.error("SET_SCALE_FAILED", "Failed to set scale: ${e.message}", e.stackTraceToString())
                }
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        activity = null
    }
}