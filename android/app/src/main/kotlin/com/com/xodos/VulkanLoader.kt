package com.com.xodos


object VulkanLoader {
    init {
        System.loadLibrary("adrenotoolstest2")   // 
    }

    external fun nativeLoadCustomDriver(driverDir: String, driverName: String, hooksDir: String): Boolean
    external fun nativeLoadSystemDriver(): Boolean
}