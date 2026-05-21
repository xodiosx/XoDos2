package com.com.xodos


object VulkanLoader {
    // Load the native library when this object is first accessed.
    // It may already be loaded by MainApplication; this is safe.
    init {
        try {
            System.loadLibrary("adrenotoolstest2")
        } catch (e: UnsatisfiedLinkError) {
            // Library not present – native methods will throw if called
        }
    }

    // New: explicit early init (called from MainApplication)
    @JvmStatic
    external fun nativeInitAdrenoTools(
        driverDir: String,
        driverName: String,
        hooksDir: String,
        tmpDir: String
    ): Boolean

    // Old methods for runtime switching (still useful)
    @JvmStatic
    external fun nativeLoadCustomDriver(
        driverDir: String,
        driverName: String,
        hooksDir: String
    ): Boolean

    @JvmStatic
    external fun nativeLoadSystemDriver(): Boolean
    @JvmStatic
external fun nativeGetDriverInfo(): String
}