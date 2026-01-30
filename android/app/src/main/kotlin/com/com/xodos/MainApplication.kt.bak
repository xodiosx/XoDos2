package com.com.xodos

import android.app.Application
import android.content.Context
import com.google.android.material.color.DynamicColors
import java.io.*

class MainApplication : Application() {

    override fun onCreate() {
        super.onCreate()
        
        // Apply dynamic colors only on Android 12+ (Material You)
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.S) {
            DynamicColors.applyToActivitiesIfAvailable(this)
        }
    }

    override fun attachBaseContext(base: Context?) {
        super.attachBaseContext(base)
        
        // REMOVED: Reflection.unseal(base) - This is the main culprit causing
        // Settings crashes and performance issues
        
        // Instead, we'll use safer alternatives for container apps
        try {
            // Initialize container support without invasive hooks
            initContainerSupport(base)
        } catch (e: Exception) {
            // Log but don't crash
            android.util.Log.e("MainApplication", "Container init failed: ${e.message}")
        }
    }
    
    private fun initContainerSupport(context: Context?) {
        // This is a safer alternative to Reflection.unseal()
        // It prepares the environment for containers without hooking system calls
        
        if (context == null) return
        
        // Set some system properties needed for container operation
        try {
            // These properties are less invasive than reflection hooks
            System.setProperty("java.io.tmpdir", "${context.filesDir}/containers/0/tmp")
            System.setProperty("user.home", "${context.filesDir}/home")
        } catch (e: SecurityException) {
            // If we can't set properties, continue anyway
            android.util.Log.w("MainApplication", "Could not set some system properties")
        }
    }
}