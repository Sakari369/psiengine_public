set(CMAKE_OSX_DEPLOYMENT_TARGET "10.13" CACHE STRING "Minimum macOS deployment target" FORCE)
project (psiengine)
#set(CMAKE_BUILD_TYPE Debug)
set(CMAKE_BUILD_TYPE Release)

cmake_minimum_required (VERSION 3.2)
set(PSI_ARCH "macos_x64")

# Add module path
cmake_policy(SET CMP0042 NEW)
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake_modules")

# Setup conan.
include(${CMAKE_BINARY_DIR}/conanbuildinfo.cmake)
conan_basic_setup()

# Setup compile flags.
add_compile_options(-Wall -std=c++14 -Wno-deprecated)
set(CMAKE_CXX_FLAGS_RELEASE "-Os -ffast-math -DNDEBUG")
set(CMAKE_CXX_FLAGS_DEBUG "-Og")

message("CMAKE_BUILD_TYPE is ${CMAKE_BUILD_TYPE}")
message("CMAKE_CXX_FLAGS_DEBUG is ${CMAKE_CXX_FLAGS_DEBUG}")
message("CMAKE_CXX_FLAGS_RELEASE is ${CMAKE_CXX_FLAGS_RELEASE}")

set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

# Main application sources.
set(SOURCES
	src/InputHandler.cpp
	src/LuaAPI.cpp
	src/main.cpp
)

set(HEADERS
	src/ProgramOptions.h
	src/InputHandler.h
	src/LuaAPI.h
	src/main.h
)

set(PSI_VENDOR_LIBS "${CMAKE_CURRENT_SOURCE_DIR}/lib/${PSI_ARCH}")
find_library(FREETYPE_GL_LIBRARY 
	NAME freetype-gl
	PATHS ${PSI_VENDOR_LIBS}
	PATH_SUFFIXES ""
	NO_DEFAULT_PATH)

set(PSI_VENDOR_SRC "${CMAKE_CURRENT_SOURCE_DIR}/src/vendor")
set(VENDOR_LUA_DIR "${PSI_VENDOR_SRC}/Lua/lua-5.3.6")

# Add Lua 5.3 from CMake sources.
# Copied from here (https://github.com/walterschell/Lua) and modified to include latest Lua 5.3.
# LuaIntF only supports Lua 5.3.
option(LUA_SUPPORT_DL "Support dynamic loading of compiled modules" OFF)
option(LUA_BUILD_AS_CXX "Build lua as C++" ON)
option(LUA_BUILD_BINARY "Build lua binary" OFF)
option(LUA_BUILD_COMPILER "Build luac compiler" OFF)
add_subdirectory(${VENDOR_LUA_DIR})
include_directories(PRIVATE "${VENDOR_LUA_DIR}/include")
set(LUA_LIBRARY ${CMAKE_BINARY_DIR}/lib/liblua.a)

# Link to the core library.
add_subdirectory(core)
add_library(core STATIC IMPORTED)
set_target_properties(core PROPERTIES IMPORTED_LOCATION
	${CMAKE_BINARY_DIR}/core/lib/libpsicore.a)

# Include header files from core.
set(PSI_CORE_ROOT "${CMAKE_CURRENT_SOURCE_DIR}/core")
include_directories("${PSI_CORE_ROOT}/src")

# Set variable for resource directory.
set(RESOURCES "${ASSETS}")
add_executable(${PROJECT_NAME} ${SOURCES} ${RESOURCES})

# Create list of all vendor libraries.
list(APPEND PSI_VENDOR_LIBRARIES ${FREETYPE_GL_LIBRARY} ${LUA_LIBRARY} ${FMOD_LIBRARIES})

# Append link directory.
target_link_directories(${PROJECT_NAME} PRIVATE "${PSI_VENDOR_LIBS}")

# Link vendor and PSI library to target.
target_link_libraries(${PROJECT_NAME} ${PSI_VENDOR_LIBRARIES} ${CONAN_LIBS} core)
install (TARGETS ${PROJECT_NAME} DESTINATION build)
