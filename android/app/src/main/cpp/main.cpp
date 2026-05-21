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

extern "C" {

JNIEXPORT jboolean JNICALL
Java_com_xodos_VulkanLoader_nativeLoadCustomDriver(
    JNIEnv *env,
    jclass /* clazz */,
    jstring j_driver_dir,
    jstring j_driver_name,
    jstring j_hooks_dir) {

    const char *driver_dir = env->GetStringUTFChars(j_driver_dir, nullptr);
    const char *driver_name = env->GetStringUTFChars(j_driver_name, nullptr);
    const char *hooks_dir = env->GetStringUTFChars(j_hooks_dir, nullptr);

    LOGI("Loading custom driver:");
    LOGI("  dir: %s", driver_dir);
    LOGI("  name: %s", driver_name);
    LOGI("  hooks: %s", hooks_dir);

    // Ensure a temp folder exists (for API < 29)
    mkdir((std::string(driver_dir) + "temp").c_str(), S_IRWXU | S_IRWXG);

    void *handle = adrenotools_open_libvulkan(
        RTLD_NOW | RTLD_LOCAL,
        ADRENOTOOLS_DRIVER_CUSTOM,
        (std::string(driver_dir) + "temp").c_str(),
        hooks_dir,
        driver_dir,
        driver_name,
        nullptr,   // fileRedirectDir
        nullptr);  // userMappingHandle

    env->ReleaseStringUTFChars(j_driver_dir, driver_dir);
    env->ReleaseStringUTFChars(j_driver_name, driver_name);
    env->ReleaseStringUTFChars(j_hooks_dir, hooks_dir);

    if (!handle) {
        LOGE("Failed to load custom driver via adrenotools");
        return JNI_FALSE;
    }

    g_vulkan_lib_handle = handle;
    LOGI("Custom driver loaded successfully!");
    return JNI_TRUE;
}

JNIEXPORT jboolean JNICALL
Java_com_xodos_VulkanLoader_nativeLoadSystemDriver(JNIEnv *env, jclass clazz) {
    if (g_vulkan_lib_handle) {
        dlclose(g_vulkan_lib_handle);
        g_vulkan_lib_handle = nullptr;
    }
    LOGI("System driver restored");
    return JNI_TRUE;
}

} // extern "C"