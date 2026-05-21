cmake_minimum_required(VERSION 3.22.1)
project("vulkan_loader")

# Add subdirectories that provide the adrenotools and sds libraries.
# If you don't need sds_library anymore, remove its add_subdirectory and linking.
add_subdirectory( adrenotools )
add_subdirectory( sds_library )

# Build our JNI loader library
add_library(vulkan_loader SHARED
        vulkan_loader.cpp   # or main.cpp if you renamed the file
)

# Link against adrenotools and Android libraries
target_link_libraries(vulkan_loader
        adrenotools
        sds_library          # remove if you drop file‑copy helpers
        android
        log
        dl
)