package com.com.xodos

import android.app.Application
import android.content.Context
import android.os.Build
import android.os.Environment
import com.google.android.material.color.DynamicColors
import me.weishu.reflection.Reflection
import java.io.BufferedReader
import java.io.File
import java.io.FileWriter
import java.io.InputStreamReader

class MainApplication : Application() {

    override fun onCreate() {
        super.onCreate()
        DynamicColors.applyToActivitiesIfAvailable(this)

        // Start logcat capture
     //   startLogcatCapture()
    }

    override fun attachBaseContext(base: Context?) {
        super.attachBaseContext(base)
        Reflection.unseal(base)
    }

    private fun startLogcatCapture() {
        Thread {
            try {
                // Determine storage folder
                val dir: File = if (Build.VERSION.SDK_INT >= 29) {
                    File(getExternalFilesDir(null), "logs")
                } else {
                    File(Environment.getExternalStorageDirectory(), "xodos/logs")
                }

                if (!dir.exists()) dir.mkdirs()

                val outFile = File(dir, "app.log")
                val writer = FileWriter(outFile, true)

                val process = Runtime.getRuntime().exec(arrayOf("logcat", "|", "grep", "xodos"))
                val reader = BufferedReader(InputStreamReader(process.inputStream))

                var line: String?
                while (reader.readLine().also { line = it } != null) {
                    writer.write(line + "\n")
                    writer.flush()
                }
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }.start()
    }
}