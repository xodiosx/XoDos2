l
# Phantom Process Killer & Signal 9 Fix (Android 11+)

This document explains how to fix error “Process completed (signal 9)”, background program kills, and closing virtual machine ir emulators on Android caused by Android Phantom Process Killer on Android 11+.


---

📌 What is Phantom Process Killer?

Android 11–14 and higher include a background-process limiter (“phantom process killer”) that kills apps or child processes when they exceed hidden limits (CPU, memory, spawn count).
This breaks:

Termux long commands

Proot / Linux chroot

Embedded YouTube videos

Background services

Wine / X11 apps

Game servers / scripts



---

✅ FIX METHODS (WORKING ON MOST DEVICES)


---

1️⃣ Disable Phantom Killer Using ADB (Most Reliable)

Works on any Android 11+, no root needed.

adb shell "/system/bin/device_config set_sync_disabled_for_tests persistent"
adb shell "/system/bin/device_config put activity_manager max_phantom_processes 2147483647"
adb shell settings put global settings_enable_monitor_phantom_procs false
adb reboot

Verify:

adb shell device_config get activity_manager max_phantom_processes

Expected output:

2147483647


---

2️⃣ Fix Using Termux (No PC Needed)

You can run ADB from Termux to your own phone using wireless debugging.

Install ADB:

pkg install android-tools

Pair with your phone:

1. Enable Developer Options


2. Enable Wireless debugging


3. Tap “Pair device with pairing code”


4. In Termux:



adb pair IP:PORT
adb connect IP:PORT

Run the fix:

adb shell "/system/bin/device_config set_sync_disabled_for_tests persistent"
adb shell "/system/bin/device_config put activity_manager max_phantom_processes 2147483647"
adb shell settings put global settings_enable_monitor_phantom_procs false
adb reboot


---

3️⃣ Fix Using Another Android Device (LAN ADB)

Device A (Controller): Install Termux
Device B (Target): Enable wireless debugging

On Device A:

pkg install android-tools
adb pair TARGET_IP:PORT
adb connect TARGET_IP:PORT

Then run the same commands as section 1.


---

4️⃣ Fix Using PC (Windows / Linux / macOS)

Windows

Install ADB from Google Platform Tools.
Then run:

adb devices
adb shell "/system/bin/device_config set_sync_disabled_for_tests persistent"
adb shell "/system/bin/device_config put activity_manager max_phantom_processes 2147483647"
adb shell settings put global settings_enable_monitor_phantom_procs false
adb reboot

Linux / macOS

Install ADB:

sudo apt install adb   # Debian/Ubuntu
brew install android-platform-tools   # macOS

Then run the same commands.


---

5️⃣ Fix Embedded YouTube Videos Using Brevent

Brevent keeps apps alive by preventing background kills.

Video example of using Brevent:

https://youtube.com/shorts/5vOUHn_qvis

Steps:

1. Install Brevent


2. Connect with ADB (first time only)


3. Enable protection for browser / app playing embedded YouTube


4. Keep Brevent service running



This reduces YouTube iframe freezes / stops on Android 11+.


---

6️⃣ Additional Notes

Make sure your app (Termux, browser, etc.) is in Battery → No Restrictions

Disable “Auto kill”, “Background restriction”, “Deep clean”, etc.

Some Chinese ROMs may ignore Google’s device_config settings

The ADB fix persists across reboots



---

📌 Tested On

Android 11

Android 12

Android 12L

Android 13

Android 14


Working on:

Samsung OneUI

Xiaomi MIUI / HyperOS

Oppo / Realme / ColorOS

Pixel / AOSP

Huawei EMUI (partial)


**more information**https://github.com/xodiosx/XoDos2/blob/main/phantom.md