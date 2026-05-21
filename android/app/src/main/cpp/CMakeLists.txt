cmake_minimum_required(VERSION 3.22.1)
project("adrenotoolstest2")

add_subdirectory(adrenotools)

# Remove sds_library if you don't need it – it was for file copy helpers
# add_subdirectory(sds_library)

add_library(adrenotoolstest2 SHARED
        main.cpp
)

target_link_libraries(adrenotoolstest2
        # game-activity::game-activity   # NOT NEEDED
        # sds_library                   # NOT NEEDED
        EGL
        GLESv3
        jnigraphics
        android
        log
        adrenotools
)