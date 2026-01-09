cmake_minimum_required(VERSION 3.20)
project(godotmark VERSION 1.0.0 LANGUAGES CXX)

# C++ Standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Build type
if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Release CACHE STRING "Build type" FORCE)
endif()

message(STATUS "Building GodotMark ${PROJECT_VERSION}")
message(STATUS "Build type: ${CMAKE_BUILD_TYPE}")
message(STATUS "Target platform: ${CMAKE_SYSTEM_NAME}")
message(STATUS "Target architecture: ${CMAKE_SYSTEM_PROCESSOR}")

# godot-cpp dependency
add_subdirectory(godot-cpp)

# GodotMark source files
file(GLOB_RECURSE SOURCES
    src/*.cpp
    src/platform/*.cpp
    src/performance/*.cpp
    src/benchmarks/*.cpp
    src/benchmarks/scenes/*.cpp
    src/results/*.cpp
)

# Create shared library
add_library(${PROJECT_NAME} SHARED ${SOURCES})

# Include directories
target_include_directories(${PROJECT_NAME} PRIVATE
    src/
    godot-cpp/include/
    godot-cpp/gen/include/
    godot-cpp/gdextension/
)

# Link godot-cpp
target_link_libraries(${PROJECT_NAME} PRIVATE godot-cpp)

# Platform-specific settings
if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
    # ARM-specific optimizations
    if(CMAKE_SYSTEM_PROCESSOR MATCHES "aarch64|arm64")
        message(STATUS "Enabling ARM64 optimizations")
        
        # Base ARM64 flags
        target_compile_options(${PROJECT_NAME} PRIVATE
            -march=armv8-a+simd
            -mfpu=neon-fp-armv8
            -ftree-vectorize
            -fvect-cost-model=cheap
        )
        
        # CPU-specific tuning (can be set via -DCPU_TARGET=rpi4)
        set(CPU_TARGET "generic" CACHE STRING "CPU target (rpi4, rpi5, orangepi5, jetson, generic)")
        
        if(CPU_TARGET STREQUAL "rpi4")
            target_compile_options(${PROJECT_NAME} PRIVATE -mcpu=cortex-a72)
            message(STATUS "Optimizing for Raspberry Pi 4 (Cortex-A72)")
        elseif(CPU_TARGET STREQUAL "rpi5")
            target_compile_options(${PROJECT_NAME} PRIVATE -mcpu=cortex-a76)
            message(STATUS "Optimizing for Raspberry Pi 5 (Cortex-A76)")
        elseif(CPU_TARGET STREQUAL "orangepi5")
            target_compile_options(${PROJECT_NAME} PRIVATE -mcpu=cortex-a76)
            message(STATUS "Optimizing for Orange Pi 5 (Cortex-A76)")
        elseif(CPU_TARGET STREQUAL "jetson")
            target_compile_options(${PROJECT_NAME} PRIVATE -mcpu=carmel)
            message(STATUS "Optimizing for NVIDIA Jetson Orin (Carmel)")
        else()
            target_compile_options(${PROJECT_NAME} PRIVATE -mcpu=cortex-a53)
            message(STATUS "Using generic ARM64 optimization (Cortex-A53)")
        endif()
    endif()
endif()

# Release build optimizations
if(CMAKE_BUILD_TYPE STREQUAL "Release")
    target_compile_options(${PROJECT_NAME} PRIVATE
        -O3
        -flto
        -ffast-math
        -fno-exceptions
        -fno-rtti
        -ffunction-sections
        -fdata-sections
        -fomit-frame-pointer
    )
    
    # Linker flags for size optimization (Linux)
    if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
        target_link_options(${PROJECT_NAME} PRIVATE
            -Wl,--gc-sections
            -Wl,--strip-all
        )
    endif()
    
    message(STATUS "Release optimizations enabled")
endif()

# Debug build flags
if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    target_compile_options(${PROJECT_NAME} PRIVATE
        -g
        -O0
    )
    target_compile_definitions(${PROJECT_NAME} PRIVATE DEBUG_ENABLED)
    message(STATUS "Debug symbols enabled")
endif()

# Output directory
set_target_properties(${PROJECT_NAME} PROPERTIES
    LIBRARY_OUTPUT_DIRECTORY "${CMAKE_SOURCE_DIR}/bin"
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_SOURCE_DIR}/bin"
)

# Installation
install(TARGETS ${PROJECT_NAME}
    LIBRARY DESTINATION lib
    RUNTIME DESTINATION bin
)

# Print build summary
message(STATUS "")
message(STATUS "============================================================")
message(STATUS "GodotMark Build Configuration")
message(STATUS "============================================================")
message(STATUS "Version:         ${PROJECT_VERSION}")
message(STATUS "Build Type:      ${CMAKE_BUILD_TYPE}")
message(STATUS "Platform:        ${CMAKE_SYSTEM_NAME}")
message(STATUS "Architecture:    ${CMAKE_SYSTEM_PROCESSOR}")
if(DEFINED CPU_TARGET)
    message(STATUS "CPU Target:      ${CPU_TARGET}")
endif()
message(STATUS "C++ Standard:    C++${CMAKE_CXX_STANDARD}")
message(STATUS "Output Directory: ${CMAKE_SOURCE_DIR}/bin")
message(STATUS "============================================================")
message(STATUS "")

