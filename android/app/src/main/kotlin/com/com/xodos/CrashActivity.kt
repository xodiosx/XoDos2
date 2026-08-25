package com.com.xodos


import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import android.os.Bundle
import android.widget.Button
import android.widget.TextView
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity

class CrashActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_crash)

        val stackTrace = intent.getStringExtra("EXTRA_STACK_TRACE") ?: "Unknown error"

        val stackTraceText = findViewById<TextView>(R.id.stackTraceText)
        val copyButton = findViewById<Button>(R.id.copyButton)
        val closeButton = findViewById<Button>(R.id.closeButton)

        stackTraceText.text = stackTrace

        copyButton.setOnClickListener {
            val clipboard = getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
            val clip = ClipData.newPlainText("Crash Log", stackTrace)
            clipboard.setPrimaryClip(clip)
            Toast.makeText(this, "Copied to clipboard", Toast.LENGTH_SHORT).show()
        }

        closeButton.setOnClickListener {
            finishAffinity()
        }
    }
}