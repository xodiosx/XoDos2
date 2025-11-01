package com.termux.app;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.Service;
import android.content.Intent;
import android.graphics.PixelFormat;
import android.os.Build;
import android.os.IBinder;
import android.util.Log;
import android.view.View;
import android.view.WindowManager;

import androidx.core.app.NotificationCompat;

import com.termux.R;

import java.io.File;
import java.io.IOException;

public class DesktopAnchorService extends Service {
    private static final String TAG = "DesktopAnchorService";
    private static final int NOTIFICATION_ID = 9099;
    private static final String CHANNEL_ID = "desktop_anchor_channel";

    private View keepAliveView;
    private WindowManager wm;
    private Process xfceProcess;

    @Override
    public void onCreate() {
        super.onCreate();
        Log.d(TAG, "XFCE anchor service created");
        createNotificationChannel();
        startForegroundNotification();

        // 🧠 Add invisible 1×1 view to mark app as visible
        try {
            wm = (WindowManager) getSystemService(WINDOW_SERVICE);
            keepAliveView = new View(this);
            WindowManager.LayoutParams params = new WindowManager.LayoutParams(
                    1, 1,
                    (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O ?
                            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY :
                            WindowManager.LayoutParams.TYPE_PHONE),
                    WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE
                            | WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE
                            | WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN,
                    PixelFormat.TRANSLUCENT
            );
            wm.addView(keepAliveView, params);
            Log.d(TAG, "Keep-alive overlay view added (1x1 px)");
        } catch (Exception e) {
            Log.e(TAG, "Failed to add keep-alive overlay view", e);
        }

        // 🧠 Start the XFCE desktop session directly from Java
        startXfceSession();
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        Log.d(TAG, "XFCE desktop anchor active - process stabilization enabled");
        return START_STICKY;
    }

    private void createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel channel = new NotificationChannel(
                    CHANNEL_ID,
                    "Desktop Environment",
                    NotificationManager.IMPORTANCE_LOW
            );
            channel.setDescription("Keeps XFCE desktop session alive");
            channel.setShowBadge(false);
            channel.setLockscreenVisibility(Notification.VISIBILITY_PRIVATE);

            NotificationManager manager = getSystemService(NotificationManager.class);
            if (manager != null) manager.createNotificationChannel(channel);
        }
    }

    private void startForegroundNotification() {
        Notification notification = new NotificationCompat.Builder(this, CHANNEL_ID)
                .setSmallIcon(R.drawable.ic_service_notification)
                .setContentTitle("XoDos Desktop")
                .setContentText("XFCE session is active")
                .setSubText("Anchor service prevents system kill")
                .setOngoing(true)
                .setShowWhen(false)
                .setPriority(NotificationCompat.PRIORITY_LOW)
                .setCategory(NotificationCompat.CATEGORY_SERVICE)
                .setVisibility(NotificationCompat.VISIBILITY_PRIVATE)
                .build();

        startForeground(NOTIFICATION_ID, notification);
    }

    private void startXfceSession() {
        new Thread(() -> {
            try {
                File homeDir = new File("/data/data/com.termux/files/home");
                File bashPath = new File("/data/data/com.termux/files/usr/bin/bash");

                if (!bashPath.exists()) {
                    Log.e(TAG, "Bash not found: " + bashPath.getAbsolutePath());
                    return;
                }

                // Modify this command if you use a custom script (like startxfce.sh)
                String[] cmd = {
                        bashPath.getAbsolutePath(),
                        "-c",
                        "export DISPLAY=:0; export PULSE_SERVER=127.0.0.1; " +
                        "nohup dbus-launch --exit-with-session startxfce4 > ~/.xsession-log 2>&1"
                };

                ProcessBuilder pb = new ProcessBuilder(cmd);
                pb.directory(homeDir);
                pb.environment().put("HOME", homeDir.getAbsolutePath());
                pb.environment().put("PATH",
                        "/data/data/com.termux/files/usr/bin:" +
                        "/data/data/com.termux/files/usr/bin");
                pb.redirectErrorStream(true);

                xfceProcess = pb.start();
                Log.d(TAG, "XFCE session started inside foreground service (process=" + xfceProcess.toString() + ")");

            } catch (IOException e) {
                Log.e(TAG, "Failed to start XFCE session", e);
            }
        }).start();
    }

    @Override
    public void onDestroy() {
        Log.w(TAG, "Desktop anchor service destroyed");

        // Clean up overlay view
        if (wm != null && keepAliveView != null) {
            try {
                wm.removeView(keepAliveView);
                Log.d(TAG, "Keep-alive overlay view removed");
            } catch (Exception e) {
                Log.e(TAG, "Failed to remove overlay view", e);
            }
        }

        // Optional: stop XFCE process when service stops
        if (xfceProcess != null) {
            xfceProcess.destroy();
            Log.w(TAG, "XFCE process terminated");
        }

        super.onDestroy();
    }

    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }
}
