# XoDos Frequently Asked Questions (FAQ)

## Table of Contents  
1. [Android 12 and above — Error Code 9](#android-12-and-above--error-code-9)  
2. [Android 13 — Notes / Issues](#android-13--notes--issues)  
3. [App crashes / disconnects after a while](#app-crashes--disconnects-after-a-while)  
4. [How to access device files?](#how-to-access-device-files)  
5. [How to access SD card files?](#how-to-access-sd-card-files)  
6. [The built-in Firefox browser can’t download files](#the-built-in-firefox-browser-can’t-download-files)  
7. [Install more software?](#install-more-software)  
8. [WPS doesn’t have common fonts?](#wps-doesn’t-have-common-fonts)  
9. [Chinese input method?](#chinese-input-method)  
10. [External mouse can’t reach screen edges?](#external-mouse-can’t-reach-screen-edges)  
11. [Mirror is synchronizing / download in progress](#mirror-is-synchronizing--download-in-progress)  
12. [Cannot find `sys/cdefs.h`](#cannot-find-syscdefsh)  
13. [Installing some software is very slow](#installing-some-software-is-very-slow)  
14. [Can MediaTek processors be used?](#can-mediatek-processors-be-used)  
15. [How to install the “Spark” app store?](#how-to-install-the-spark-app-store)  
16. [Display too small, hard to read text?](#display-too-small-hard-to-read-text)  
17. [No sound in container / environment](#no-sound-in-container--environment)  

---

### Android 12 and above — Error Code 9  
If your system version is **Android 12 or higher**, the software may exit unexpectedly with *Error Code 9*. In that case, the app provides a [fix guide](https://github.com/xodiosx/XoDos2/blob/main/signal9fix.md) to help you recover. The fix isn’t automatic (due to permission limitations), but you can follow the steps manually, or go to the advanced settings and navigate to the error page.  

### Android 13 — Notes / Issues  
On **Android 13 or above**, some web-apps (e.g. Jupyter Notebook, Bilibili client, etc.) may not work properly. To mitigate this, go to global settings and enable the “getifaddrs bridging” option.  

### App crashes / disconnects after a while  
If the application crashes or disconnects after some time, that may be caused by Error Code 9 (see above). If it happens again, press the “back” button (or use the back gesture) — the app might show the repair guide again so you can fix the issue manually.  

### How to access device files?  
If you grant storage permission, you can access device storage via the main directory folders. To access the entire device storage, open the “sd” folder — many user-directory folders (like Downloads) are mapped to actual device storage paths. In addition, any Android app supporting SAF (Storage Access Framework) can access the files without launching this software.  

### How to access SD card files?  
First, use another file manager to find the SD card path (usually something like `/storage/xxxx…`). Then enter that full path in the “file manager” of this software. Do *not* just enter `/storage/`, or browse from there — that usually lacks permission. If the path is not under `/storage/...`, you likely won’t have permission access.  

### The built-in Firefox browser can’t download files  
If downloads via the built-in Firefox fail, check whether the app has been granted the “all files access” permission. Downloads go to the device’s Downloads folder by default; if permission is missing, download will fail. Alternatively, you can change the download save location in Firefox’s settings.  

### Install more software?  
This software is meant to be a lightweight PC-application engine — it does **not** support installing arbitrary software out-of-the-box (other than some apps like WPS). If you want to install additional software, you can try using the built-in `tmoe` or `pi-apps`  tools — but success is not guaranteed. In fact, even components such as VSCode and input methods are installed via `tmoe`. You can also search online for e.g. “Debian install arm64 X” or “Linux install arm64 X” tutorials, but you may need to manually patch things. For example, browsers and Electron-based apps often need a `--no-sandbox` flag to run correctly in this container-like environment.  

### WPS doesn’t have common fonts?  
If you need more fonts, you can manually copy any font files into the `Fonts` folder in device storage (after giving the app storage permission). Many common fonts can be found on a Windows PC under `C:\Windows\Fonts`. Due to potential licensing/copyright concerns, this software cannot provide fonts directly.  

### Chinese input method?  
It’s strongly recommended **not** to use Android’s Chinese input methods directly for typing Chinese. Instead, use the container’s internal input method — switch with `Ctrl + Space`. Starting from version 1.0.3, Chinese input is supported in AVNC: when you type Chinese, the software sends it via clipboard then performs a `Shift + Insert` to paste; if your terminal doesn’t support that, input may not work. For terminal apps, sometimes you need `Ctrl + Shift + Insert` to paste or using the built in copy paste buttons. If that doesn’t work, you can still use the container’s input method.  

### External mouse can’t reach screen edges?  
This usually happens if your device uses gesture controls instead of physical navigation buttons — the edges might be reserved for gestures. There isn’t a guaranteed fix, but you can try a pinch gesture (two-finger pinch) to shrink the screen slightly. As of version 1.0.2, AVNC and Termux:X11 enable “mouse capture,” which should resolve this issue in many cases.  

### Mirror is synchronizing / download in progress  
Sometimes you may see messages that “the mirror is synchronizing.” This simply means the repository mirror is being updated. Wait a while (a few hours) and try again later — the sync should eventually complete.  

### Cannot find `sys/cdefs.h`  
If you get errors like “cannot find `sys/cdefs.h`” when compiling C programs, there was a known issue. Starting from version 1.0.2, this problem should be resolved.  

### Installing some software is very slow  
If software installations are abnormally slow, this is often a side-effect of the container environment / network / mirror issues. Try changing the mirror, or reinstalling the bootstrap packages (if available).  

### Can MediaTek processors be used?  
Yes — devices with MediaTek processors can work. The only limitation is that there is no mature open-source graphics driver with acceleration support; so performance may be lower. If you don’t care about graphics acceleration, the software should still run and always try to enable virgl if it doesn't work disable it and use CPU default.  

### How to install the “Spark” app store?  
If you want to install the “Spark” app store, Alternatively, you can use pi-apps built in or install "Spark" manually via the provided “quick-command”. Note: the default Desktop GUI version does **not** include Spark. Many apps installed via Spark may not work properly because this container environment differs from a full Linux system.  

### Display too small, hard to read text?  
If the display is too small or text is hard to read, you can adjust interface scaling — see the control settings tap.  

### No sound in container / environment  
If there is no sound, try going to *Control → Global Settings → Reinstall boot package*, then restart the software. This often restores audio functionality and can fix some other issues.
