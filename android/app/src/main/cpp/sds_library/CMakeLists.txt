cmake_minimum_required( VERSION 3.10 )
project( sds_library )

include( CMake/Bootstrap.cmake )

add_recursive( ${CMAKE_CURRENT_SOURCE_DIR}/src SOURCES )
add_recursive( ${CMAKE_CURRENT_SOURCE_DIR}/include HEADERS )

add_library( ${PROJECT_NAME} STATIC ${SOURCES} ${HEADERS} )

target_include_directories( ${PROJECT_NAME}
	PUBLIC
		"${CMAKE_CURRENT_SOURCE_DIR}/include"
)
