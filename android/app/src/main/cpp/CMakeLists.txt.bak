cmake_minimum_required(VERSION 3.22.1)
project("adrenotoolstest2")

add_subdirectory(adrenotools)
add_subdirectory(sds_library)

add_library(adrenotoolstest2 SHARED
        main.cpp          # ← this now contains the JNI functions
)

find_package(game-activity REQUIRED CONFIG)

target_link_libraries(adrenotoolstest2
        game-activity::game-activity
        sds_library
        EGL
        GLESv3
        jnigraphics
        android
        log
        adrenotools
)