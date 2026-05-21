#include <jni.h>
#include <string>
#include <dlfcn.h>
#include <sys/stat.h>
#include <android/log.h>
#include <adrenotools/driver.h>

#define LOG_TAG "VulkanLoader"
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)

static void *g_vulkan_lib_handle = nullptr;

// Native implementations
static jboolean loadCustomDriver(JNIEnv *env, jclass clazz, jstring driverDir, jstring driverName, jstring hooksDir) {
    const char *driver_dir = env->GetStringUTFChars(driverDir, nullptr);
    const char *driver_name = env->GetStringUTFChars(driverName, nullptr);
    const char *hooks_dir = env->GetStringUTFChars(hooksDir, nullptr);

    LOGI("Loading custom driver:");
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

    // Try the known correct name first, then a common fallback.
    const char *classNames[] = {
        "com/com/xodos/VulkanLoader",   // matches your actual package
        "com/xodos/VulkanLoader"        // fallback if you ever change it
    };

    jclass cls = nullptr;
    for (const char *name : classNames) {
        cls = env->FindClass(name);
        if (env->ExceptionCheck()) {
            env->ExceptionClear();   // <-- THIS FIXES THE CRASH
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