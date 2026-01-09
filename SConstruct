#!/usr/bin/env python
import os
import sys

# GodotMark Build Configuration
# Optimized for ARM Single-Board Computers (Raspberry Pi 4, Orange Pi 5, Jetson Orin)

env = SConscript("godot-cpp/SConstruct")

# Project configuration
env.Append(CPPPATH=["src/"])
sources = []

# Collect all source files
sources += Glob("src/*.cpp")
sources += Glob("src/platform/*.cpp")
sources += Glob("src/performance/*.cpp")
sources += Glob("src/benchmarks/*.cpp")
sources += Glob("src/benchmarks/scenes/*.cpp")
sources += Glob("src/results/*.cpp")

# Platform-specific optimizations
platform = env["platform"]
arch = env.get("arch", "")
target = env["target"]

# Get CPU target from command line (default: generic)
cpu_target = ARGUMENTS.get("cpu", "generic")

print(f"Building GodotMark for {platform} ({arch}) - {target} - CPU: {cpu_target}")

# ARM-specific optimizations
if arch == "arm64" or platform == "linux":
    # Base ARM64 flags (NEON is built-in for ARM64, no -mfpu needed)
    arm_flags = [
        "-march=armv8-a+simd",      # ARM64 with NEON SIMD
        "-ftree-vectorize",          # Auto-vectorization
        "-fvect-cost-model=cheap",   # Aggressive vectorization
    ]
    
    # CPU-specific tuning
    cpu_flags = {
        "rpi4": ["-mcpu=cortex-a72"],                    # Raspberry Pi 4
        "rpi5": ["-mcpu=cortex-a76"],                    # Raspberry Pi 5
        "orangepi5": ["-mcpu=cortex-a76"],               # Orange Pi 5 (RK3588)
        "rock5b": ["-mcpu=cortex-a76"],                  # Rock 5B (RK3588)
        "jetson": ["-mcpu=carmel"],                      # NVIDIA Jetson Orin
        "generic": ["-mcpu=cortex-a53"],                 # Generic ARM64
    }
    
    if cpu_target in cpu_flags:
        arm_flags.extend(cpu_flags[cpu_target])
        print(f"  → Optimizing for: {cpu_target}")
    
    env.Append(CCFLAGS=arm_flags)

# Release build optimizations
if target == "template_release":
    optimization_flags = [
        "-O3",                       # Maximum optimization
        "-flto",                     # Link-time optimization
        "-ffast-math",               # Fast math (acceptable for benchmarks)
        "-fno-exceptions",           # No exceptions (embedded best practice)
        # NOTE: -fno-rtti removed - godot-cpp 4.4 uses dynamic_cast and requires RTTI
        "-ffunction-sections",       # Enable dead code elimination
        "-fdata-sections",
        "-fomit-frame-pointer",      # Omit frame pointer (more registers)
    ]
    
    env.Append(CCFLAGS=optimization_flags)
    
    # Linker flags for size optimization
    if platform == "linux":
        env.Append(LINKFLAGS=[
            "-Wl,--gc-sections",     # Remove unused sections
            "-Wl,--strip-all",       # Strip symbols
        ])

# Debug build flags
elif target == "template_debug":
    debug_flags = [
        "-g",                        # Debug symbols
        "-O0",                       # No optimization
        "-DDEBUG_ENABLED",           # Debug macros
    ]
    env.Append(CCFLAGS=debug_flags)

# Size optimization option (for memory-constrained devices)
if ARGUMENTS.get("optimize_size", "no") == "yes":
    print("  → Size optimization enabled")
    env.Append(CCFLAGS=["-Os", "-fomit-frame-pointer"])

# Verbose output option
if ARGUMENTS.get("verbose", "no") == "yes":
    env["VERBOSE"] = True

# Build the library
library_name = "libgodotmark{}{}".format(env["suffix"], env["SHLIBSUFFIX"])
library_path = "bin/{}".format(library_name)

# Ensure bin directory exists
if not os.path.exists("bin"):
    os.makedirs("bin")

library = env.SharedLibrary(library_path, source=sources)

Default(library)

# Print build summary
print("\n" + "="*60)
print("GodotMark Build Configuration")
print("="*60)
print(f"Platform:        {platform}")
print(f"Architecture:    {arch if arch else 'native'}")
print(f"Target:          {target}")
print(f"CPU Optimization: {cpu_target}")
print(f"Output:          {library_path}")
print("="*60 + "\n")

