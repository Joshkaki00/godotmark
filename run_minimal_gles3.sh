#!/bin/bash

# Run minimal test with GLES3 renderer (lower overhead on RPi)
# This bypasses Vulkan driver overhead

echo "=========================================="
echo "MINIMAL TEST - GLES3 RENDERER"
echo "Target: Test if OpenGL has lower overhead"
echo "=========================================="
echo ""

# Force GLES3 renderer
./godot --rendering-driver opengl3 --path . res://scenes/benchmarks/02_nature_island_minimal.tscn

echo ""
echo "=========================================="
echo "Test complete - check FPS difference"
echo "=========================================="
