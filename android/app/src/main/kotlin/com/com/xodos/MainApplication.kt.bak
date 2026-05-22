package com.com.xodos

import android.app.Application
import android.content.Context
import com.google.android.material.color.DynamicColors
import me.weishu.reflection.Reflection
import java.io.File

class MainApplication : Application() {

    override fun attachBaseContext(base: Context?) {
        super.attachBaseContext(base)
        // Unseal reflection – keep this if you need it
        if (base != null) {
            Reflection.unseal(base)
        }

        // 1. Load the native library (JNI_OnLoad will only register methods)
        try {
            System.loadLibrary("adrenotoolstest2")
        } catch (e: UnsatisfiedLinkError) {
            // Library not found – no custom driver loading possible
            return
        }

        // 2. Read active driver file (three lines: driverDir, driverName, hooksDir)
        val driverFile = File(applicationInfo.dataDir, "files/active_driver.txt")
        if (!driverFile.exists()) {
            return   // No custom driver selected – use system driver
        }

        val lines = try {
            driverFile.readLines()
        } catch (e: Exception) {
            return
        }

        if (lines.size < 3) {
            return
        }

        val driverDir = lines[0].trim()
        val driverName = lines[1].trim()
        val hooksDir = applicationInfo.nativeLibraryDir   // always correct

        // 3. Call the native init function to load the custom driver
        val tmpDir = applicationInfo.dataDir + "/files/adrenotools-temp"
        try {
            VulkanLoader.nativeInitAdrenoTools(driverDir, driverName, hooksDir, tmpDir)
        } catch (e: Exception) {
            // Native method not found (library not loaded) – ignore
        }
    }

    override fun onCreate() {
        super.onCreate()
        DynamicColors.applyToActivitiesIfAvailable(this@MainApplication)
    }
}