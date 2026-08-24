package com.example.x11_flutter

import android.content.Intent
import android.os.Handler
import android.os.Looper
import android.system.Os.setenv
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import kotlin.concurrent.thread

/** X11FlutterPlugin */
class X11FlutterPlugin: FlutterPlugin, MethodCallHandler, ActivityAware {
    private lateinit var channel: MethodChannel
    private var activity: android.app.Activity? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "x11_flutter")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "launchXServer" -> {
                val act = activity
                if (act == null) {
                    result.error("NO_ACTIVITY", "Activity context missing", null)
                    return
                }

                try {
                    val tmpdir = call.argument<String>("tmpdir")
                    val xkb = call.argument<String>("xkb")
                    val xserverArgs = call.argument<List<String>>("xserverArgs")
                    
                    if (tmpdir == null || xkb == null || xserverArgs == null) {
                        result.error("INVALID_ARGUMENTS", "tmpdir, xkb and xserverArgs arguments are required", null)
                        return
                    }

                    // Set Environment Variables
                    setenv("TMPDIR", tmpdir, true)
                    setenv("XKB_CONFIG_ROOT", xkb, true)
                    setenv("TERMUX_X11_DEBUG", "1", true)
                    setenv("TERMUX_X11_OVERRIDE_PACKAGE", act.packageName, true)
                    
                    // Assign valid context to CmdEntryPoint before invocation
                    com.termux.x11.CmdEntryPoint.ctx = act.applicationContext

                    // Execute CmdEntryPoint on a background thread to prevent blocking Main UI thread
                    thread(start = true, name = "XServerThread") {
                        try {
                            com.termux.x11.CmdEntryPoint.main(xserverArgs.toTypedArray())
                        } catch (e: Exception) {
                            e.printStackTrace()
                        }
                    }

                    result.success(0)
                } catch (e: Exception) {
                    result.error("LAUNCH_XSERVER_FAILED", "Failed to launch X server: ${e.message}", e.stackTraceToString())
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
                        val intent = Intent(it, com.termux.x11.MainActivity::class.java).apply {
                            // Ensure MainActivity is brought to top or launched freshly
                            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)
                        }
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
                    val act = activity ?: run {
                        result.error("NO_ACTIVITY", "No activity context available", null)
                        return
                    }
                    val intent = Intent("com.termux.x11.CHANGE_PREFERENCE").apply {
                        putExtra("tc_displayScale", scale.toString())
                        setPackage(act.packageName)
                    }
                    act.sendBroadcast(intent)
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
