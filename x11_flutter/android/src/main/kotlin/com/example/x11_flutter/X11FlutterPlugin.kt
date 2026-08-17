package com.example.x11_flutter

import android.content.Intent
import android.os.Looper
import android.system.Os.setenv
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
                    val tmpdir = call.argument<String>("tmpdir")
                    val xkb = call.argument<String>("xkb")
                    val xserverArgs = call.argument<List<String>>("xserverArgs")

                    if (tmpdir == null || xkb == null || xserverArgs == null) {
                        result.error("INVALID_ARGUMENTS", "tmpdir, xkb and xserverArgs arguments are required", null)
                        return
                    }

                    // Set environment variables
                    setenv("TMPDIR", tmpdir, true)
                    setenv("XKB_CONFIG_ROOT", xkb, true)
                    setenv("TERMUX_X11_DEBUG", "1", true)
                    setenv("TERMUX_X11_OVERRIDE_PACKAGE", activity!!.packageName, true)

                    val appContext = activity!!.applicationContext

                    // Start the X server on a dedicated thread with its own Looper,
                    // using the original CmdEntryPoint.main() entry point.
                    Thread {
                        try {
                            Looper.prepare()

                            // Load the class (static block runs here and creates a Handler with this Looper)
                            val cmdClass = Class.forName("com.termux.x11.CmdEntryPoint")

                            // Set the static context to the application context (needed by native code)
                            val ctxField = cmdClass.getDeclaredField("ctx")
                            ctxField.isAccessible = true
                            ctxField.set(null, appContext)

                            // Call main(args) – it will start the server and enter its own Looper.loop()
                            val mainMethod = cmdClass.getMethod("main", Array<String>::class.java)
                            mainMethod.invoke(null, xserverArgs.toTypedArray())

                            // main() blocks on Looper.loop(), so we never reach here
                        } catch (e: Exception) {
                            Log.e("X11Flutter", "CmdEntryPoint.main failed", e)
                        }
                    }.start()

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