
# 🛡️ Disable Phantom Process Killer (Android 11–14) — No PC Required

This guide explains how to disable Android's **Phantom Process Killer** WITHOUT using a computer.  
Phantom Process Killer is responsible for killing background apps like Termux, XoDos, Linux, emulators, Linux desktop environment, and vmos virtual machine etc.

---

# ⚠️ What Phantom Process Killer Does

Android 11–14 introduced a background restriction system that:

- Kills apps when they run too many background processes  
- Interrupts Linux processes 
- Kills Termux XoDos or any terminal Apps with `Signal 9`  
- Breaks Proot, Linux distros, and Wine  
- Restarts games when minimized  
- Closes Discord / Telegram when switching apps  

This guide stops that behavior safely using **Fix Tool / Wireless Debugging / Shizuku**.

---

# ✔ Method 1 — Disable Phantom Process Killer Using Fix App (No PC)

Works on **ALL devices with Android 11+**.

### Steps:

1. Install the Fix App:
   **https://github.com/xodiosx/XoDos/releases/tag/fix-5.3**

2. Open the app  
3. Tap **"Apply Phantom Killer Fix"**  
4. Enable **Wireless Debugging** when prompted:
   - Go to Settings → Developer Options  
   - Enable **Developer Options**  
   - Enable **Wireless Debugging**

5. The app will automatically:
   - Pair with your device  
   - Run the required ADB commands internally  
   - Apply the fix permanently  

### What this fixes:
✔ Termux killed instantly (signal 9)  
✔ Proot / Linux processes crashing  
✔ Wine closing during gameplay  
✔ background processes killing 
✔ Apps restarting when minimized  

---

# ✔ Method 2 — Disable Phantom Killer with Wireless ADB (Manual, No PC)

You only need your phone — no computer.

### Step 1 — Enable Wireless Debugging

Settings → Developer Options → **Wireless Debugging**

### Step 2 — Install an ADB Shell App

Install one of these (non-root):
- **LADB** (recommended)  
- **Bugjaeger ADB** 
- **Brevent APK**: https://drive.google.com/file/d/14Z57iKidS0aiwVt2e4edjsMGeeykAJ0W/view?usp=drivesdk
- **Shizuku (ADB mode)**  

### Step 3 — Run These Commands (Corrected & Safe)

Copy-paste into LADB/Bugjaeger:

```bash
device_config set_sync_disabled_for_tests persistent
device_config put activity_manager max_phantom_processes 2147483647
settings put global settings_enable_monitor_phantom_procs false
```
note: — some devices after Rebooting the phone needs to disable Phantom process again same process above

✔ Phantom process killing is now disabled.


---

✔ Method 3 — Disable Phantom Killer Using Shizuku (No ADB Commands)

Shizuku lets apps run privileged ADB commands without needing a PC.

Steps:

1. Install Shizuku from Play Store


2. Open Shizuku → tap Start via Wireless Debugging


3. Pair it


4. Install the Fix App (XoDos Fix)


5. Tap Apply Fix (Shizuku mode)



The Fix App will automatically run the phantom killer override through Shizuku.


---

🔧 Full Commands Used Internally (For Reference)

These are the commands executed by Fix Tool and Shizuku mode:

adb shell device_config set_sync_disabled_for_tests persistent
adb shell device_config put activity_manager max_phantom_processes 2147483647
adb shell settings put global settings_enable_monitor_phantom_procs false

These make Android stop killing background processes aggressively.


---

🎯 What Improves After the Fix

After disabling Phantom Process Killer:

Termux and XoDos and other Linux environment apps no longer dies

Proot/Ubuntu/Debian remain alive

Wine gaming becomes stable

VM and virtual machines Apps remain alive

Apps stop restarting when minimized

Browsers don’t reload tabs

Discord & Telegram stay alive

Background downloads don't pause



---

🧪 Verification Test

To confirm it works:

1. Open Termux


2. Run a long process (ping, python script, Linux boot)

```
echo '#!/data/data/com.termux/files/usr/bin/bash

echo "Starting test CPU heavy task for phantom process killer..."

while true; do
    openssl rand -base64 4096 > /dev/null 
done' > test.sh 
chmod +x ./test.sh
./test.sh &
```
watch it if it's killed or disappeared then Phantom process killer close it
```
logcat | grep -i phantom
```


3. Turn screen off or switch apps

4. If it continues running → fix is active just force close termux or kill test.sh

```

pkill -f test.sh
```




---
**more information**https://github.com/xodiosx/XoDos2/signal9fix.md


📅 Last Updated

December 2025 — XoDos team


