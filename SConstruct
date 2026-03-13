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

# ARM-specific optimizations (only for ARM architectures)
if arch == "arm64":
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

# Add clean target
if GetOption('clean'):
    print("\n" + "="*60)
    print("Cleaning build artifacts...")
    print("="*60)
    print("Note: Use ./clean.py, ./clean.sh, or ./clean.ps1 for thorough cleaning")
    print("="*60 + "\n")

# Add help alias
env.Help("""
GodotMark Build System
======================

USAGE:
  scons [options]

COMMON OPTIONS:
  platform=<platform>    Target platform (linux, windows, macos)
  target=<target>        Build type (template_debug, template_release)
  cpu=<cpu>              CPU optimization (rpi4, rpi5, orangepi5, rock5b, generic)
  arch=<arch>            Architecture (x86_64, arm64)
  optimize_size=yes      Enable size optimization (-Os)
  verbose=yes            Verbose build output
  -c, --clean            Clean build artifacts (use clean.py for thorough clean)
  -j<n>                  Parallel build with N jobs

EXAMPLES:
  # Raspberry Pi 5 release build
  scons platform=linux target=template_release cpu=rpi5 arch=arm64 -j4
  
  # Debug build with verbose output
  scons platform=linux target=template_debug verbose=yes
  
  # Clean build
  scons -c
  
  # Thorough clean (recommended)
  python clean.py
  # or
  ./clean.sh        # Linux/Mac
  ./clean.ps1       # Windows

CPU TARGETS:
  rpi4       - Raspberry Pi 4 (Cortex-A72)
  rpi5       - Raspberry Pi 5 (Cortex-A76)
  orangepi5  - Orange Pi 5 (RK3588)
  rock5b     - Rock 5B (RK3588)
  jetson     - NVIDIA Jetson Orin
  generic    - Generic ARM64 (default)

For more information, see BUILD_AND_RUN.md
""")

# Print build summary
print("\n" + "="*60)
print("GodotMark Build Configuration")
print("="*60)
print(f"Platform:         {platform}")
print(f"Architecture:     {arch if arch else 'native'}")
print(f"Target:           {target}")
print(f"CPU Optimization: {cpu_target}")
print(f"Output:           {library_path}")
print("="*60 + "\n")

