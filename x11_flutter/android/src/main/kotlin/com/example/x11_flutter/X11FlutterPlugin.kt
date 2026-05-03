package com.example.x11_flutter

import android.system.Os.setenv

import android.content.Intent
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

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
    try {
        val tmpdir = call.argument<String>("tmpdir")
        val xkb = call.argument<String>("xkb")
        val xserverArgs = call.argument<List<String>>("xserverArgs")

        if (tmpdir == null || xkb == null || xserverArgs == null) {
            result.error("INVALID_ARGUMENTS", "tmpdir, xkb and xserverArgs arguments are required", null)
            return
        }

        // Path to the termux-x11 script inside XoDos's environment.
        // Adjust if your prefix is different.
        val termuxX11Binary = "/data/data/com.xodos/files/usr/bin/termux-x11"

        // Build the command: termux-x11 <display_number>
        // The display number is usually the first argument.
        val command = listOf(termuxX11Binary) + xserverArgs

        val processBuilder = ProcessBuilder(command)
            .directory(android.os.Environment.getExternalStorageDirectory()) // any writable dir
            .redirectErrorStream(true)

        // Set the environment variables needed by the script and the loader
        val env = processBuilder.environment()
        env["TMPDIR"] = tmpdir
        env["XKB_CONFIG_ROOT"] = xkb
        env["TERMUX_X11_DEBUG"] = "1"
        // Tell the loader which package to look for (your own APK)
        env["TERMUX_X11_OVERRIDE_PACKAGE"] = activity!!.packageName

        // Start the process (do not wait – it runs in the background)
        processBuilder.start()

        // Return immediately; the X server will be running in its own process
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