package com.termux.app;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.Service;
import android.content.Intent;
import android.os.Build;
import android.os.IBinder;
import android.util.Log;
import androidx.core.app.NotificationCompat;
import com.termux.R;

public class DesktopAnchorService extends Service {
    private static final String TAG = "DesktopAnchorService";
    private static final int NOTIFICATION_ID = 9099;
    private static final String CHANNEL_ID = "desktop_anchor_channel";
    
    @Override
    public void onCreate() {
        super.onCreate();
        Log.d(TAG, "XFCE anchor service created");
        createNotificationChannel();
        startForegroundNotification();
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
            if (manager != null) {
                manager.createNotificationChannel(channel);
            }
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

    @Override
    public void onDestroy() {
        Log.w(TAG, "Desktop anchor service destroyed");
        super.onDestroy();
    }

    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }
}