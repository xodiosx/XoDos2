package com.example.avnc_flutter

import android.app.Activity
import android.content.Context
import android.content.Intent
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding

/** AvncFlutterPlugin */
class AvncFlutterPlugin: FlutterPlugin, MethodCallHandler, ActivityAware {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private lateinit var context : Context
  private var activity : Activity? = null

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    context = flutterPluginBinding.applicationContext
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "avnc_flutter")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
        "launchUsingUri" -> {
            com.gaurav.avnc.ui.vnc.startVncActivity(activity!!, com.gaurav.avnc.vnc.VncUri(call.argument("vncUri")!!).toServerProfile().apply {
                call.argument<Boolean>("resizeRemoteDesktop")?.also { resizeRemoteDesktop = it }
                call.argument<Double>("resizeRemoteDesktopScaleFactor")?.also { resizeRemoteDesktopScaleFactor = it.toFloat() }
            })
            result.success(0)
        }
        "launchPrefsPage" -> {
            activity!!.startActivity(Intent(activity!!, com.gaurav.avnc.ui.prefs.PrefsActivity::class.java))
            result.success(0)
        }
        "launchAboutPage" -> {
            activity!!.startActivity(Intent(activity!!, com.gaurav.avnc.ui.about.AboutActivity::class.java))
            result.success(0)
        }
        else -> result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onDetachedFromActivity() {
    activity = null
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    activity = binding.activity
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity
  }

  override fun onDetachedFromActivityForConfigChanges() {
    activity = null
  }
}
