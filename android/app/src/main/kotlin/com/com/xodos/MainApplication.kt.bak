package com.com.xodos

import android.app.Application
import android.content.Context
import com.google.android.material.color.DynamicColors
import me.weishu.reflection.Reflection
import java.io.*

class MainApplication : FlutterApplication() {

    override fun onCreate() {
        super.onCreate()
        DynamicColors.applyToActivitiesIfAvailable(this@MainApplication)
    }

    override fun attachBaseContext(base: Context?) {
        super.attachBaseContext(base)
        Reflection.unseal(base)
    }
}