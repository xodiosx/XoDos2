#include <jni.h>
#include <string>
#include <dlfcn.h>
#include <sys/stat.h>
#include <android/log.h>
#include <adrenotools/driver.h>

#define LOG_TAG "VulkanLoader"
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)

// --------------------------------------------------------------------------
// Optional helpers (from the original test) – you may keep them for debug
// --------------------------------------------------------------------------

static void testVulkan(void *libVulkan) {
    PFN_vkCreateInstance vkCreateInstance =
        reinterpret_cast<PFN_vkCreateInstance>(dlsym(libVulkan, "vkCreateInstance"));
    PFN_vkDestroyInstance vkDestroyInstance =
        reinterpret_cast<PFN_vkDestroyInstance>(dlsym(libVulkan, "vkDestroyInstance"));
    PFN_vkEnumeratePhysicalDevices vkEnumeratePhysicalDevices =
        reinterpret_cast<PFN_vkEnumeratePhysicalDevices>(
            dlsym(libVulkan, "vkEnumeratePhysicalDevices"));
    PFN_vkGetPhysicalDeviceProperties vkGetPhysicalDeviceProperties =
        reinterpret_cast<PFN_vkGetPhysicalDeviceProperties>(
            dlsym(libVulkan, "vkGetPhysicalDeviceProperties"));

    VkApplicationInfo appInfo = {};
    appInfo.sType = VK_STRUCTURE_TYPE_APPLICATION_INFO;
    appInfo.pApplicationName = "Adrenotools";
    appInfo.apiVersion = VK_API_VERSION_1_0;

    VkInstanceCreateInfo createInfo = {};
    createInfo.sType = VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO;
    createInfo.pApplicationInfo = &appInfo;

    VkInstance instance;
    vkCreateInstance(&createInfo, nullptr, &instance);

    uint32_t count = 0;
    vkEnumeratePhysicalDevices(instance, &count, nullptr);
    if (count == 0) {
        LOGI("No Vulkan physical devices found!");
    } else {
        std::vector<VkPhysicalDevice> devices(count);
        vkEnumeratePhysicalDevices(instance, &count, devices.data());
        for (uint32_t i = 0; i < count; ++i) {
            VkPhysicalDeviceProperties props;
            vkGetPhysicalDeviceProperties(devices[i], &props);
            LOGI("Device %d: %s, driver version 0x%08x",
                 i, props.deviceName, props.driverVersion);
        }
    }
    vkDestroyInstance(instance, nullptr);
}

static void loadOriginalVulkan() {
    void *mod = dlopen("libvulkan.so", RTLD_NOW | RTLD_LOCAL);
    if (!mod) {
        LOGE("Could not open original Vulkan: %s", dlerror());
        return;
    }
    LOGI("=== Testing original driver ===");
    testVulkan(mod);
    dlclose(mod);
}

static void replaceDriver(const std::string &path, const char *hooksDir, const char *driverName) {
    mkdir((path + "temp").c_str(), S_IRWXU | S_IRWXG);

    void *lib = adrenotools_open_libvulkan(
        RTLD_NOW | RTLD_LOCAL,
        ADRENOTOOLS_DRIVER_CUSTOM,
        (path + "temp").c_str(),
        hooksDir,
        path.c_str(),
        driverName,
        nullptr, nullptr);

    if (lib) {
        LOGI("Custom driver loaded, testing...");
        testVulkan(lib);
    } else {
        LOGE("adrenotools_open_libvulkan failed: %s", dlerror());
    }
}

// --------------------------------------------------------------------------
// Global handle for the loaded driver (used by the whole process)
// --------------------------------------------------------------------------
static void *g_vulkan_lib_handle = nullptr;

extern "C" {

// --------------------------------------------------------------------------
// JNI functions – called from Kotlin/Dart via MethodChannel
// --------------------------------------------------------------------------
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

    mkdir((std::string(driver_dir) + "temp").c_str(), S_IRWXU | S_IRWXG);

    void *handle = adrenotools_open_libvulkan(
        RTLD_NOW | RTLD_LOCAL,
        ADRENOTOOLS_DRIVER_CUSTOM,
        (std::string(driver_dir) + "temp").c_str(),
        hooks_dir,
        driver_dir,
        driver_name,
        nullptr, nullptr);

    env->ReleaseStringUTFChars(j_driver_dir, driver_dir);
    env->ReleaseStringUTFChars(j_driver_name, driver_name);
    env->ReleaseStringUTFChars(j_hooks_dir, hooks_dir);

    if (!handle) {
        LOGE("Failed to load custom driver via adrenotools");
        return JNI_FALSE;
    }

    g_vulkan_lib_handle = handle;
    LOGI("Custom driver loaded successfully!");

    // Optional: run a quick test (can be removed in production)
    testVulkan(handle);

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