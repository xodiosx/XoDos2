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

// --------------------------------------------------------------------------
// Core loading function (unchanged)
// --------------------------------------------------------------------------
static bool initAdrenoTools(const char *driverDir,
                            const char *driverName,
                            const char *hooksDir,
                            const char *tmpDir) {
    if (!driverDir || !driverName || !hooksDir || !tmpDir) {
        LOGE("initAdrenoTools: null argument");
        return false;
    }

    if (g_vulkan_lib_handle) {
        LOGI("Custom driver already loaded, skipping.");
        return true;
    }

    std::string tempDir = std::string(tmpDir) + "/adrenotools-temp";
    mkdir(tempDir.c_str(), 0700);

    LOGI("Calling adrenotools_open_libvulkan:");
    LOGI("  driverDir: %s", driverDir);
    LOGI("  driverName: %s", driverName);
    LOGI("  hooksDir: %s", hooksDir);
    LOGI("  tmpDir: %s", tempDir.c_str());

    g_vulkan_lib_handle = adrenotools_open_libvulkan(
        RTLD_NOW | RTLD_LOCAL,
        ADRENOTOOLS_DRIVER_CUSTOM,
        tempDir.c_str(),
        hooksDir,
        driverDir,
        driverName,
        nullptr,   // fileRedirectDir
        nullptr    // userMappingHandle
    );

    if (!g_vulkan_lib_handle) {
        LOGE("adrenotools_open_libvulkan failed: %s", dlerror());
        return false;
    }

    LOGI("Custom driver loaded successfully!");
    return true;
}

// --------------------------------------------------------------------------
// Helper: retrieve driver info from the loaded Vulkan library
// --------------------------------------------------------------------------
static std::string getDriverInfoJson() {
    if (!g_vulkan_lib_handle) {
        return "{}";
    }

    // Load necessary Vulkan functions from the custom driver handle
    auto vkCreateInstance = (PFN_vkCreateInstance)dlsym(g_vulkan_lib_handle, "vkCreateInstance");
    auto vkDestroyInstance = (PFN_vkDestroyInstance)dlsym(g_vulkan_lib_handle, "vkDestroyInstance");
    auto vkEnumeratePhysicalDevices = (PFN_vkEnumeratePhysicalDevices)dlsym(g_vulkan_lib_handle, "vkEnumeratePhysicalDevices");
    auto vkGetPhysicalDeviceProperties = (PFN_vkGetPhysicalDeviceProperties)dlsym(g_vulkan_lib_handle, "vkGetPhysicalDeviceProperties");

    if (!vkCreateInstance || !vkDestroyInstance || !vkEnumeratePhysicalDevices || !vkGetPhysicalDeviceProperties) {
        LOGE("Failed to load Vulkan functions from custom driver");
        return "{}";
    }

    VkApplicationInfo appInfo = {};
    appInfo.sType = VK_STRUCTURE_TYPE_APPLICATION_INFO;
    appInfo.pApplicationName = "AdrenotoolsInfo";
    appInfo.apiVersion = VK_API_VERSION_1_0;

    VkInstanceCreateInfo createInfo = {};
    createInfo.sType = VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO;
    createInfo.pApplicationInfo = &appInfo;

    VkInstance instance;
    if (vkCreateInstance(&createInfo, nullptr, &instance) != VK_SUCCESS) {
        LOGE("Failed to create Vulkan instance for info query");
        return "{}";
    }

    uint32_t deviceCount = 0;
    vkEnumeratePhysicalDevices(instance, &deviceCount, nullptr);
    if (deviceCount == 0) {
        vkDestroyInstance(instance, nullptr);
        return "{}";
    }

    VkPhysicalDevice physicalDevice;
    vkEnumeratePhysicalDevices(instance, &deviceCount, &physicalDevice);

    VkPhysicalDeviceProperties props;
    vkGetPhysicalDeviceProperties(physicalDevice, &props);

    vkDestroyInstance(instance, nullptr);

    // Build JSON string
    char json[512];
    snprintf(json, sizeof(json),
             R"({"deviceName":"%s","driverVersion":"%d.%d.%d"})",
             props.deviceName,
             VK_API_VERSION_MAJOR(props.driverVersion),
             VK_API_VERSION_MINOR(props.driverVersion),
             VK_API_VERSION_PATCH(props.driverVersion));
    return std::string(json);
}

// --------------------------------------------------------------------------
// JNI: explicit early init (called from MainApplication)
// --------------------------------------------------------------------------
extern "C" JNIEXPORT jboolean JNICALL
Java_com_xodos_VulkanLoader_nativeInitAdrenoTools(
    JNIEnv *env, jclass clazz,
    jstring jDriverDir, jstring jDriverName,
    jstring jHooksDir, jstring jTmpDir) {

    const char *driverDir = env->GetStringUTFChars(jDriverDir, nullptr);
    const char *driverName = env->GetStringUTFChars(jDriverName, nullptr);
    const char *hooksDir = env->GetStringUTFChars(jHooksDir, nullptr);
    const char *tmpDir = env->GetStringUTFChars(jTmpDir, nullptr);

    bool ok = initAdrenoTools(driverDir, driverName, hooksDir, tmpDir);

    env->ReleaseStringUTFChars(jDriverDir, driverDir);
    env->ReleaseStringUTFChars(jDriverName, driverName);
    env->ReleaseStringUTFChars(jHooksDir, hooksDir);
    env->ReleaseStringUTFChars(jTmpDir, tmpDir);

    return ok ? JNI_TRUE : JNI_FALSE;
}

// --------------------------------------------------------------------------
// JNI: runtime load (old method)
// --------------------------------------------------------------------------
extern "C" JNIEXPORT jboolean JNICALL
Java_com_xodos_VulkanLoader_nativeLoadCustomDriver(
    JNIEnv *env, jclass clazz,
    jstring jDriverDir, jstring jDriverName, jstring jHooksDir) {

    const char *driverDir = env->GetStringUTFChars(jDriverDir, nullptr);
    const char *driverName = env->GetStringUTFChars(jDriverName, nullptr);
    const char *hooksDir = env->GetStringUTFChars(jHooksDir, nullptr);

    std::string tmpDir = std::string(driverDir) + "temp";
    bool ok = initAdrenoTools(driverDir, driverName, hooksDir, tmpDir.c_str());

    env->ReleaseStringUTFChars(jDriverDir, driverDir);
    env->ReleaseStringUTFChars(jDriverName, driverName);
    env->ReleaseStringUTFChars(jHooksDir, hooksDir);

    return ok ? JNI_TRUE : JNI_FALSE;
}

extern "C" JNIEXPORT jboolean JNICALL
Java_com_xodos_VulkanLoader_nativeLoadSystemDriver(JNIEnv *env, jclass clazz) {
    if (g_vulkan_lib_handle) {
        dlclose(g_vulkan_lib_handle);
        g_vulkan_lib_handle = nullptr;
    }
    LOGI("System driver restored");
    return JNI_TRUE;
}

// --------------------------------------------------------------------------
// JNI: get driver info as JSON string
// --------------------------------------------------------------------------
extern "C" JNIEXPORT jstring JNICALL
Java_com_xodos_VulkanLoader_nativeGetDriverInfo(JNIEnv *env, jclass clazz) {
    std::string json = getDriverInfoJson();
    return env->NewStringUTF(json.c_str());
}

// --------------------------------------------------------------------------
// JNI_OnLoad – register all methods
// --------------------------------------------------------------------------
JNIEXPORT jint JNI_OnLoad(JavaVM *vm, void *reserved) {
    JNIEnv *env;
    if (vm->GetEnv((void **)&env, JNI_VERSION_1_6) != JNI_OK) {
        return JNI_ERR;
    }

    const JNINativeMethod methods[] = {
        {"nativeInitAdrenoTools",
         "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Z",
         (void *)Java_com_xodos_VulkanLoader_nativeInitAdrenoTools},
        {"nativeLoadCustomDriver",
         "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Z",
         (void *)Java_com_xodos_VulkanLoader_nativeLoadCustomDriver},
        {"nativeLoadSystemDriver",
         "()Z",
         (void *)Java_com_xodos_VulkanLoader_nativeLoadSystemDriver},
        {"nativeGetDriverInfo",
         "()Ljava/lang/String;",
         (void *)Java_com_xodos_VulkanLoader_nativeGetDriverInfo},
    };

    const char *classNames[] = {
        "com/xodos/VulkanLoader",
        "com/com/xodos/VulkanLoader"
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