package com.com.xodos

import android.app.Application
import android.content.Context
import com.google.android.material.color.DynamicColors
import me.weishu.reflection.Reflection
import java.io.*

class MainApplication : Application() {

    private var logcatProcess: Process? = null

    override fun attachBaseContext(base: Context?) {
        super.attachBaseContext(base)
        Reflection.unseal(base)
    }

    override fun onCreate() {
        super.onCreate()
        DynamicColors.applyToActivitiesIfAvailable(this)

        clearLogcat()
        startLogcatCapture()
    }

    override fun onTerminate() {
        super.onTerminate()
        logcatProcess?.destroy()
    }

    private fun clearLogcat() {
        try {
            Runtime.getRuntime().exec("logcat -c")
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun startLogcatCapture() {
        Thread {
            try {
                val logDir = File(getExternalFilesDir(null), "logs")
                if (!logDir.exists()) logDir.mkdirs()

                // Overwrite each launch
                val logFile = File(logDir, "app.log")
                val writer = BufferedWriter(FileWriter(logFile, false))

                val command = arrayOf(
                    "logcat",
                    "-v", "time"
                )

                logcatProcess = Runtime.getRuntime().exec(command)

                val reader = BufferedReader(
                    InputStreamReader(logcatProcess!!.inputStream)
                )

                var line: String?
                while (reader.readLine().also { line = it } != null) {
                    writer.write(line!!)
                    writer.newLine()
                    writer.flush()
                }

                reader.close()
                writer.close()

            } catch (e: Exception) {
                e.printStackTrace()
            }
        }.start()
    }
}