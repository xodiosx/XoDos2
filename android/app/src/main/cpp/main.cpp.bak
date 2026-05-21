#include <jni.h>
#include <string>
#include <dlfcn.h>
#include <sys/stat.h>
#include <android/log.h>
#include <fstream>
#include <adrenotools/driver.h>

#define LOG_TAG "VulkanLoader"
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)

static void *g_vulkan_lib_handle = nullptr;

// Path to the active‑driver indicator file (written by Dart manager)
static const char *kActiveDriverFilePath = "/data/data/com.xodos/files/active_driver.txt";

// Called from JNI_OnLoad BEFORE any Vulkan usage.
static void loadSavedCustomDriver() {
    std::ifstream file(kActiveDriverFilePath);
    if (!file.is_open()) {
        LOGI("No active driver file – using system driver");
        return;
    }

    std::string driverDir, driverName, hooksDir;
    if (!std::getline(file, driverDir) ||
        !std::getline(file, driverName) ||
        !std::getline(file, hooksDir)) {
        LOGE("Active driver file is malformed (expecting 3 lines)");
        return;
    }
    file.close();

    LOGI("Loading custom driver from file:");
    LOGI("  dir: %s", driverDir.c_str());
    LOGI("  name: %s", driverName.c_str());
    LOGI("  hooks: %s", hooksDir.c_str());

    mkdir((driverDir + "temp").c_str(), S_IRWXU | S_IRWXG);

    void *handle = adrenotools_open_libvulkan(
        RTLD_NOW | RTLD_LOCAL,
        ADRENOTOOLS_DRIVER_CUSTOM,
        (driverDir + "temp").c_str(),
        hooksDir.c_str(),   // now a valid string from the file
        driverDir.c_str(),
        driverName.c_str(),
        nullptr, nullptr);

    if (!handle) {
        LOGE("Failed to load custom driver: %s", dlerror());
        return;
    }

    g_vulkan_lib_handle = handle;
    LOGI("Custom driver loaded successfully at startup!");
}

// JNI methods (still callable from Dart for runtime switching)
static jboolean loadCustomDriver(JNIEnv *env, jclass clazz, jstring driverDir, jstring driverName, jstring hooksDir) {
    const char *driver_dir = env->GetStringUTFChars(driverDir, nullptr);
    const char *driver_name = env->GetStringUTFChars(driverName, nullptr);
    const char *hooks_dir = env->GetStringUTFChars(hooksDir, nullptr);

    LOGI("Loading custom driver (manual call):");
    LOGI("  dir: %s", driver_dir);
    LOGI("  name: %s", driver_name);
    LOGI("  hooks: %s", hooks_dir);

    mkdir((std::string(driver_dir) + "temp").c_str(), S_IRWXU | S_IRWXG);

    void *handle = adrenotools_open_libvulkan(
        RTLD_NOW | RTLD_LOCAL,
        ADRENOTOOLS_DRIVER_CUSTOM,
        (std::string(driver_dir) + "temp").c_str(),
        hooks_dir,
        driver_dir,
        driver_name,
        nullptr, nullptr);

    env->ReleaseStringUTFChars(driverDir, driver_dir);
    env->ReleaseStringUTFChars(driverName, driver_name);
    env->ReleaseStringUTFChars(hooksDir, hooks_dir);

    if (!handle) {
        LOGE("Failed to load custom driver via adrenotools");
        return JNI_FALSE;
    }

    g_vulkan_lib_handle = handle;
    LOGI("Custom driver loaded successfully!");
    return JNI_TRUE;
}

static jboolean loadSystemDriver(JNIEnv *env, jclass clazz) {
    if (g_vulkan_lib_handle) {
        dlclose(g_vulkan_lib_handle);
        g_vulkan_lib_handle = nullptr;
    }
    LOGI("System driver restored");
    return JNI_TRUE;
}

static const JNINativeMethod methods[] = {
    {"nativeLoadCustomDriver", "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Z", (void *)loadCustomDriver},
    {"nativeLoadSystemDriver", "()Z", (void *)loadSystemDriver},
};

JNIEXPORT jint JNI_OnLoad(JavaVM *vm, void *reserved) {
    JNIEnv *env;
    if (vm->GetEnv((void **)&env, JNI_VERSION_1_6) != JNI_OK) {
        return JNI_ERR;
    }

    // 1. Immediately load a previously saved custom driver (if any)
    loadSavedCustomDriver();

    // 2. Register JNI methods for the VulkanLoader class
    const char *classNames[] = {
        "com/com/xodos/VulkanLoader",
        "com/xodos/VulkanLoader"
    };
    jclass cls = nullptr;
    for (const char *name : classNames) {
        cls = env->FindClass(name);
        if (env->ExceptionCheck()) {
            env->ExceptionClear();
        }
        if (cls != nullptr) break;
    }
    if (cls == nullptr) {
        LOGE("Failed to find VulkanLoader class");
        return JNI_ERR;
    }
    if (env->RegisterNatives(cls, methods, sizeof(methods) / sizeof(methods[0])) < 0) {
        LOGE("Failed to register native methods");
        return JNI_ERR;
    }
    return JNI_VERSION_1_6;
}