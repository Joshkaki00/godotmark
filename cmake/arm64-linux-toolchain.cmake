# ARM64 Linux Cross-Compilation Toolchain
# For building GodotMark on Windows/x86_64 targeting ARM64 Linux (Raspberry Pi 4, etc.)

set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR aarch64)

# Cross-compiler paths
# Option 1: LLVM/Clang (if installed)
if(EXISTS "C:/Program Files/LLVM/bin/clang.exe")
    set(CMAKE_C_COMPILER "C:/Program Files/LLVM/bin/clang.exe")
    set(CMAKE_CXX_COMPILER "C:/Program Files/LLVM/bin/clang++.exe")
    set(CMAKE_C_COMPILER_TARGET aarch64-linux-gnu)
    set(CMAKE_CXX_COMPILER_TARGET aarch64-linux-gnu)
    message(STATUS "Using LLVM/Clang for ARM64 cross-compilation")
    
# Option 2: ARM GNU Toolchain (if installed)
elseif(EXISTS "C:/Program Files/ARM/bin/aarch64-none-linux-gnu-gcc.exe")
    set(CMAKE_C_COMPILER "C:/Program Files/ARM/bin/aarch64-none-linux-gnu-gcc.exe")
    set(CMAKE_CXX_COMPILER "C:/Program Files/ARM/bin/aarch64-none-linux-gnu-g++.exe")
    message(STATUS "Using ARM GNU Toolchain for ARM64 cross-compilation")
    
# Option 3: WSL2 (fallback)
else()
    message(WARNING "No ARM64 cross-compiler found!")
    message(WARNING "Please install one of:")
    message(WARNING "  1. LLVM/Clang: winget install LLVM.LLVM")
    message(WARNING "  2. ARM GNU Toolchain: https://developer.arm.com/downloads/-/arm-gnu-toolchain-downloads")
    message(WARNING "  3. Use WSL2: wsl --install")
endif()

# Sysroot (adjust if you have an ARM64 sysroot)
# set(CMAKE_SYSROOT /path/to/arm64/sysroot)

# Search paths
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

# ARM64-specific flags
set(CMAKE_C_FLAGS_INIT "-march=armv8-a")
set(CMAKE_CXX_FLAGS_INIT "-march=armv8-a")

message(STATUS "ARM64 Linux toolchain configured")

