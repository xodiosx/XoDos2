cmake_minimum_required(VERSION 3.22.1)
project("adrenotoolstest2")

# Add the adrenotools static library (contains all hook code)
add_subdirectory(adrenotools)

# Uncomment the next line only if you still use sds_library helpers
# add_subdirectory(sds_library)

# Build our main native library
add_library(adrenotoolstest2 SHARED
        main.cpp
)

# Link against the necessary Android and adrenotools libraries
target_link_libraries(adrenotoolstest2
        adrenotools
        android
        log
        dl
        # sds_library          # uncomment if you keep it
        # EGL GLESv3 jnigraphics  # not needed unless you render natively
)