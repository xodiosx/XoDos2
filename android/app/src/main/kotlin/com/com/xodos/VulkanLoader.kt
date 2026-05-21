package com.xodos

import android.util.Log
import io.flutter.plugin.common.MethodChannel

object VulkanLoader {
    private const val TAG = "VulkanLoader"

    // Native methods
    external fun nativeLoadCustomDriver(driverDir: String, driverName: String, hooksDir: String): Boolean
    external fun nativeLoadSystemDriver(): Boolean

    init {
        System.loadLibrary("vulkan_loader")   // same name as your shared library
    }
}