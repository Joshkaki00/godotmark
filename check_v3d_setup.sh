#!/bin/bash
#
# V3D Driver Setup Verification Script
# Quick diagnostic tool to check V3D/Vulkan driver configuration
#

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}  V3D Driver Setup Check${NC}"
echo -e "${BLUE}============================================${NC}"
echo ""

# Overall status
ALL_GOOD=true

# ============================================================================
# System Info
# ============================================================================

echo -e "${BLUE}=== System Information ===${NC}"
if [ -f /proc/device-tree/model ]; then
    MODEL=$(cat /proc/device-tree/model | tr -d '\0')
    echo "Model: $MODEL"
else
    echo -e "${RED}✗ Not a Raspberry Pi${NC}"
    ALL_GOOD=false
fi

RAM_MB=$(free -m | awk 'NR==2 {print $2}')
echo "RAM: ${RAM_MB} MB"

if [ -f /etc/os-release ]; then
    . /etc/os-release
    echo "OS: $PRETTY_NAME"
fi

echo ""

# ============================================================================
# Config.txt Check
# ============================================================================

echo -e "${BLUE}=== Boot Configuration ===${NC}"

# Find config.txt
if [ -f /boot/firmware/config.txt ]; then
    CONFIG_PATH="/boot/firmware/config.txt"
elif [ -f /boot/config.txt ]; then
    CONFIG_PATH="/boot/config.txt"
else
    echo -e "${RED}✗ config.txt not found${NC}"
    ALL_GOOD=false
    CONFIG_PATH=""
fi

if [ -n "$CONFIG_PATH" ]; then
    echo "Config: $CONFIG_PATH"
    
    if grep -q "^dtoverlay=vc4-kms-v3d" "$CONFIG_PATH"; then
        echo -e "${GREEN}✓ V3D overlay enabled${NC}"
    elif grep -q "^#dtoverlay=vc4-kms-v3d" "$CONFIG_PATH"; then
        echo -e "${YELLOW}⚠ V3D overlay commented out (disabled)${NC}"
        echo "  Run: sudo ./install_v3d_stack.sh"
        ALL_GOOD=false
    else
        echo -e "${RED}✗ V3D overlay not configured${NC}"
        echo "  Run: sudo ./install_v3d_stack.sh"
        ALL_GOOD=false
    fi
    
    if grep -q "^max_framebuffers" "$CONFIG_PATH"; then
        FRAMEBUFFERS=$(grep "^max_framebuffers" "$CONFIG_PATH" | cut -d= -f2)
        echo "  max_framebuffers: $FRAMEBUFFERS"
    fi
fi

echo ""

# ============================================================================
# V3D Kernel Module
# ============================================================================

echo -e "${BLUE}=== V3D Kernel Module ===${NC}"

if lsmod | grep -q "^v3d"; then
    echo -e "${GREEN}✓ V3D module loaded${NC}"
    V3D_INFO=$(lsmod | grep "^v3d")
    echo "  $V3D_INFO"
else
    echo -e "${RED}✗ V3D module not loaded${NC}"
    echo "  This usually means you need to reboot after configuration."
    ALL_GOOD=false
fi

echo ""

# ============================================================================
# DRI Devices
# ============================================================================

echo -e "${BLUE}=== DRI Devices ===${NC}"

if [ -d /dev/dri ]; then
    if ls /dev/dri/renderD* &> /dev/null; then
        echo -e "${GREEN}✓ Render devices found:${NC}"
        ls -la /dev/dri/ | grep "renderD\|card" | while read line; do
            echo "  $line"
        done
    else
        echo -e "${YELLOW}⚠ /dev/dri exists but no render devices${NC}"
        ls -la /dev/dri/
        ALL_GOOD=false
    fi
else
    echo -e "${RED}✗ /dev/dri directory not found${NC}"
    echo "  Reboot may be required"
    ALL_GOOD=false
fi

echo ""

# ============================================================================
# OpenGL Info
# ============================================================================

echo -e "${BLUE}=== OpenGL Information ===${NC}"

if command -v glxinfo &> /dev/null; then
    if glxinfo &> /dev/null; then
        GL_VENDOR=$(glxinfo 2>/dev/null | grep "OpenGL vendor" | cut -d: -f2 | xargs || echo "Unknown")
        GL_RENDERER=$(glxinfo 2>/dev/null | grep "OpenGL renderer" | cut -d: -f2 | xargs || echo "Unknown")
        GL_VERSION=$(glxinfo 2>/dev/null | grep "OpenGL version" | cut -d: -f2 | xargs || echo "Unknown")
        GL_ES_VERSION=$(glxinfo 2>/dev/null | grep "OpenGL ES profile version" | cut -d: -f2 | xargs || echo "Unknown")
        
        echo -e "${GREEN}✓ OpenGL available${NC}"
        echo "  Vendor: $GL_VENDOR"
        echo "  Renderer: $GL_RENDERER"
        echo "  Version: $GL_VERSION"
        echo "  ES Version: $GL_ES_VERSION"
        
        # Check if it's software rendering
        if echo "$GL_RENDERER" | grep -qi "llvmpipe\|software"; then
            echo -e "${YELLOW}  ⚠ WARNING: Using software rendering!${NC}"
            ALL_GOOD=false
        fi
    else
        echo -e "${YELLOW}⚠ glxinfo available but cannot query OpenGL${NC}"
        ALL_GOOD=false
    fi
else
    echo -e "${YELLOW}⚠ glxinfo not installed${NC}"
    echo "  Install with: sudo apt install mesa-utils"
fi

echo ""

# ============================================================================
# Vulkan Info
# ============================================================================

echo -e "${BLUE}=== Vulkan Information ===${NC}"

if command -v vulkaninfo &> /dev/null; then
    if vulkaninfo --summary &> /dev/null; then
        # Get device info
        DEVICE_NAME=$(vulkaninfo 2>/dev/null | grep "deviceName" | head -1 | cut -d= -f2 | xargs || echo "Unknown")
        API_VERSION=$(vulkaninfo 2>/dev/null | grep "apiVersion" | head -1 | cut -d= -f2 | xargs || echo "Unknown")
        DRIVER_VERSION=$(vulkaninfo 2>/dev/null | grep "driverVersion" | head -1 | cut -d= -f2 | xargs || echo "Unknown")
        
        echo -e "${GREEN}✓ Vulkan available${NC}"
        echo "  Device: $DEVICE_NAME"
        echo "  API Version: $API_VERSION"
        echo "  Driver Version: $DRIVER_VERSION"
        
        # Check for V3D
        if echo "$DEVICE_NAME" | grep -qi "v3d"; then
            echo -e "${GREEN}  ✓ V3D Vulkan driver active${NC}"
        else
            echo -e "${YELLOW}  ⚠ Non-V3D Vulkan driver${NC}"
        fi
    else
        echo -e "${YELLOW}⚠ vulkaninfo available but cannot query Vulkan${NC}"
        echo "  This may mean Vulkan drivers are not properly installed."
        ALL_GOOD=false
    fi
else
    echo -e "${YELLOW}⚠ vulkaninfo not installed${NC}"
    echo "  Install with: sudo apt install vulkan-tools"
fi

echo ""

# ============================================================================
# Mesa Package Info
# ============================================================================

echo -e "${BLUE}=== Mesa Packages ===${NC}"

if command -v dpkg &> /dev/null; then
    if dpkg -l | grep -q mesa-vulkan-drivers; then
        MESA_VERSION=$(dpkg -l | grep mesa-vulkan-drivers | awk '{print $3}')
        echo -e "${GREEN}✓ mesa-vulkan-drivers installed${NC}"
        echo "  Version: $MESA_VERSION"
    else
        echo -e "${RED}✗ mesa-vulkan-drivers not installed${NC}"
        echo "  Install with: sudo apt install mesa-vulkan-drivers"
        ALL_GOOD=false
    fi
    
    if dpkg -l | grep -q libvulkan1; then
        VULKAN_VERSION=$(dpkg -l | grep "^ii  libvulkan1" | awk '{print $3}')
        echo -e "${GREEN}✓ libvulkan1 installed${NC}"
        echo "  Version: $VULKAN_VERSION"
    else
        echo -e "${RED}✗ libvulkan1 not installed${NC}"
        echo "  Install with: sudo apt install libvulkan1"
        ALL_GOOD=false
    fi
fi

echo ""

# ============================================================================
# Summary
# ============================================================================

echo -e "${BLUE}============================================${NC}"
if [ "$ALL_GOOD" = true ]; then
    echo -e "${GREEN}✓ All checks passed!${NC}"
    echo ""
    echo "Your V3D driver stack is properly configured."
    echo "You're ready to run GodotMark!"
else
    echo -e "${YELLOW}⚠ Some issues detected${NC}"
    echo ""
    echo "Recommended actions:"
    echo "  1. Run: sudo ./install_v3d_stack.sh"
    echo "  2. Reboot if config changes were made"
    echo "  3. Run this script again to verify"
fi
echo -e "${BLUE}============================================${NC}"
echo ""

