package com.example.x11_flutter

import android.system.Os.setenv
import android.content.Intent
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class X11FlutterPlugin: FlutterPlugin, MethodCallHandler, ActivityAware {

    private lateinit var channel: MethodChannel
    private var activity: android.app.Activity? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "x11_flutter")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {

            "launchXServer" -> {
                try {
                    val tmpdir = call.argument<String>("tmpdir")
                    val xkb = call.argument<String>("xkb")
                    val xserverArgs = call.argument<List<String>>("xserverArgs")

                    if (tmpdir == null || xkb == null || xserverArgs == null) {
                        result.error("INVALID_ARGUMENTS", "tmpdir, xkb and xserverArgs required", null)
                        return
                    }

                    // 🌍 Environment setup
                    setenv("TMPDIR", tmpdir, true)
                    setenv("XKB_CONFIG_ROOT", xkb, true)
                    setenv("TERMUX_X11_DEBUG", "1", true)
                    setenv("TERMUX_X11_OVERRIDE_PACKAGE", activity!!.packageName, true)

                    // ⚡ Performance tuning
                    setenv("MESA_GLTHREAD", "true", true)
                    setenv("vblank_mode", "0", true)

                    // 🚀 Run X11 in background thread (CRITICAL FIX)
                    Thread {
                        try {
                            Log.i("X11", "Starting X11 server thread...")
                            com.termux.x11.CmdEntryPoint.main(xserverArgs.toTypedArray())
                        } catch (e: Exception) {
                            Log.e("X11", "X11 crashed: ${e.message}")
                        }
                    }.start()

                    result.success(0)

                } catch (e: Exception) {
                    result.error("LAUNCH_XSERVER_FAILED", e.message, e.stackTraceToString())
                }
            }

            "launchX11Page" -> {
                try {
                    activity?.let {
                        val intent = Intent(it, com.termux.x11.MainActivity::class.java).apply {
                            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        }
                        it.startActivity(intent)
                        result.success(0)
                    } ?: result.error("NO_ACTIVITY", "No activity", null)

                } catch (e: Exception) {
                    result.error("LAUNCH_X11_PAGE_FAILED", e.message, e.stackTraceToString())
                }
            }

            "launchX11PrefsPage" -> {
                try {
                    activity?.let {
                        val intent = Intent(it, com.termux.x11.LoriePreferences::class.java).apply {
                            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        }
                        it.startActivity(intent)
                        result.success(0)
                    } ?: result.error("NO_ACTIVITY", "No activity", null)

                } catch (e: Exception) {
                    result.error("LAUNCH_PREFS_FAILED", e.message, e.stackTraceToString())
                }
            }

            "setScale" -> {
                try {
                    val scale = call.argument<Double>("scale")
                        ?: return result.error("INVALID_ARGUMENTS", "scale required", null)

                    val intent = Intent("com.termux.x11.CHANGE_PREFERENCE").apply {
                        putExtra("tc_displayScale", scale.toString())
                        setPackage(activity!!.packageName)
                    }

                    activity!!.sendBroadcast(intent)
                    result.success(0)

                } catch (e: Exception) {
                    result.error("SET_SCALE_FAILED", e.message, e.stackTraceToString())
                }
            }

            else -> result.notImplemented()
        }
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() { activity = null }
    override fun onDetachedFromActivityForConfigChanges() { activity = null }
    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}