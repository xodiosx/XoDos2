package com.com.xodos

import android.app.Application
import android.content.Context
import android.content.Intent
import android.os.Handler
import android.os.Looper
import android.os.Process
import android.util.Log
import com.google.android.material.color.DynamicColors
import me.weishu.reflection.Reflection
import java.io.PrintWriter
import java.io.StringWriter

class MainApplication : Application() {

    override fun onCreate() {
        super.onCreate()
        DynamicColors.applyToActivitiesIfAvailable(this@MainApplication)

        // Set up global crash handler
        val defaultHandler = Thread.getDefaultUncaughtExceptionHandler()
        Thread.setDefaultUncaughtExceptionHandler { thread, throwable ->
            // Convert stack trace to string
            val sw = StringWriter()
            val pw = PrintWriter(sw)
            throwable.printStackTrace(pw)
            val stackTraceString = sw.toString()

            // Log the crash
            Log.e("CrashHandler", "Uncaught exception", throwable)

            // Launch CrashActivity
            val intent = Intent(this, CrashActivity::class.java).apply {
                putExtra("EXTRA_STACK_TRACE", stackTraceString)
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK)
            }
            startActivity(intent)

            // Kill the process after a short delay so the activity can be displayed
            Handler(Looper.getMainLooper()).postDelayed({
                Process.killProcess(Process.myPid())
                System.exit(10)
            }, 1000)

            // Do NOT call defaultHandler to avoid the system crash dialog
        }
    }

    override fun attachBaseContext(base: Context?) {
        super.attachBaseContext(base)
        Reflection.unseal(base)
    }
}