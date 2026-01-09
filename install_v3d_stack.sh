#!/bin/bash
#
# V3D Driver Stack Installer for Raspberry Pi
# Optimizes graphics driver configuration for GodotMark benchmark
# Supports Raspberry Pi 4 (4GB) and Raspberry Pi 5
#

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Banner
echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}  V3D Driver Stack Installer${NC}"
echo -e "${BLUE}  for Raspberry Pi 4/5${NC}"
echo -e "${BLUE}============================================${NC}"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}Error: This script must be run as root (use sudo)${NC}"
    exit 1
fi

# Store original user for later
ORIGINAL_USER=${SUDO_USER:-$USER}

# ============================================================================
# 1. SYSTEM DETECTION
# ============================================================================

echo -e "${BLUE}[1/6] Detecting system...${NC}"

# Check if Raspberry Pi
if [ ! -f /proc/device-tree/model ]; then
    echo -e "${RED}Error: Not running on a Raspberry Pi${NC}"
    exit 1
fi

MODEL=$(cat /proc/device-tree/model | tr -d '\0')
echo "  Detected: $MODEL"

# Detect Pi version
if echo "$MODEL" | grep -q "Raspberry Pi 4"; then
    PI_VERSION="4"
    echo -e "  ${GREEN}✓ Raspberry Pi 4 detected${NC}"
elif echo "$MODEL" | grep -q "Raspberry Pi 5"; then
    PI_VERSION="5"
    echo -e "  ${GREEN}✓ Raspberry Pi 5 detected${NC}"
else
    echo -e "${YELLOW}Warning: Unrecognized Raspberry Pi model${NC}"
    echo -n "  Continue anyway? (y/N): "
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo "Installation cancelled."
        exit 0
    fi
    PI_VERSION="unknown"
fi

# Detect OS version
if [ -f /etc/os-release ]; then
    . /etc/os-release
    echo "  OS: $PRETTY_NAME"
fi

# Check RAM
RAM_MB=$(free -m | awk 'NR==2 {print $2}')
echo "  RAM: ${RAM_MB} MB"

echo ""

# ============================================================================
# 2. CONFIG.TXT SETUP
# ============================================================================

echo -e "${BLUE}[2/6] Configuring boot settings...${NC}"

# Find config.txt location (changes between OS versions)
if [ -f /boot/firmware/config.txt ]; then
    CONFIG_PATH="/boot/firmware/config.txt"
elif [ -f /boot/config.txt ]; then
    CONFIG_PATH="/boot/config.txt"
else
    echo -e "${RED}Error: Could not find config.txt${NC}"
    exit 1
fi

echo "  Config file: $CONFIG_PATH"

# Backup config.txt
BACKUP_PATH="${CONFIG_PATH}.backup.$(date +%Y%m%d_%H%M%S)"
echo "  Creating backup: $BACKUP_PATH"
cp "$CONFIG_PATH" "$BACKUP_PATH"

# Check if V3D overlay already enabled
if grep -q "^dtoverlay=vc4-kms-v3d" "$CONFIG_PATH"; then
    echo -e "  ${GREEN}✓ V3D overlay already enabled${NC}"
else
    echo -e "  ${YELLOW}Enabling V3D overlay...${NC}"
    
    # Add configuration
    echo "" >> "$CONFIG_PATH"
    echo "# V3D Graphics Driver (added by install_v3d_stack.sh)" >> "$CONFIG_PATH"
    if [ "$PI_VERSION" = "4" ]; then
        echo "[pi4]" >> "$CONFIG_PATH"
    elif [ "$PI_VERSION" = "5" ]; then
        echo "[pi5]" >> "$CONFIG_PATH"
    else
        echo "[all]" >> "$CONFIG_PATH"
    fi
    echo "dtoverlay=vc4-kms-v3d" >> "$CONFIG_PATH"
    echo "max_framebuffers=2" >> "$CONFIG_PATH"
    
    # Enable 64-bit for Pi 4 with 4GB+ RAM
    if [ "$PI_VERSION" = "4" ] && [ "$RAM_MB" -ge 4000 ]; then
        if ! grep -q "^arm_64bit=1" "$CONFIG_PATH"; then
            echo "arm_64bit=1" >> "$CONFIG_PATH"
            echo -e "  ${GREEN}✓ Enabled 64-bit mode${NC}"
        fi
    fi
    
    echo -e "  ${GREEN}✓ V3D overlay configuration added${NC}"
fi

echo ""

# ============================================================================
# 3. MESA PACKAGE UPGRADE
# ============================================================================

echo -e "${BLUE}[3/6] Installing/upgrading Mesa packages...${NC}"
echo "  This may take several minutes..."
echo ""

# Update package lists
echo "  Updating package lists..."
apt update -qq

# Install/upgrade Mesa and Vulkan packages
echo "  Installing Mesa Vulkan drivers..."
apt install -y mesa-vulkan-drivers libvulkan1 2>&1 | grep -v "^debconf:" || true

echo "  Upgrading Mesa packages..."
apt install -y --only-upgrade mesa-* libgles* libgl1-mesa-* 2>&1 | grep -v "^debconf:" || true

echo -e "  ${GREEN}✓ Mesa packages installed/upgraded${NC}"
echo ""

# ============================================================================
# 4. VULKAN TOOLS AND VALIDATION
# ============================================================================

echo -e "${BLUE}[4/6] Installing Vulkan tools...${NC}"

# Install Vulkan tools
apt install -y vulkan-tools mesa-utils 2>&1 | grep -v "^debconf:" || true

# Ask about validation layers (optional, large package)
echo ""
echo -n "  Install Vulkan validation layers? (useful for debugging, ~50MB) (y/N): "
read -r response
if [[ "$response" =~ ^[Yy]$ ]]; then
    apt install -y vulkan-validationlayers 2>&1 | grep -v "^debconf:" || true
    echo -e "  ${GREEN}✓ Validation layers installed${NC}"
fi

echo -e "  ${GREEN}✓ Vulkan tools installed${NC}"
echo ""

# ============================================================================
# 5. VERIFICATION TESTS
# ============================================================================

echo -e "${BLUE}[5/6] Running verification tests...${NC}"

# Check if V3D module is currently loaded (requires reboot if config just changed)
echo "  Checking V3D kernel module..."
if lsmod | grep -q v3d; then
    echo -e "  ${GREEN}✓ V3D module is loaded${NC}"
else
    echo -e "  ${YELLOW}⚠ V3D module not loaded (reboot required)${NC}"
fi

# Check DRI device
echo "  Checking DRI devices..."
if [ -d /dev/dri ]; then
    ls -la /dev/dri/ | grep "renderD\|card" || echo "  No render devices found yet"
else
    echo -e "  ${YELLOW}⚠ /dev/dri not found (reboot required)${NC}"
fi

# Check OpenGL (may not work without reboot)
echo "  Checking OpenGL support..."
if command -v glxinfo &> /dev/null; then
    GL_VERSION=$(glxinfo 2>/dev/null | grep "OpenGL version" | head -1 || echo "Not available")
    if [ "$GL_VERSION" != "Not available" ]; then
        echo "  $GL_VERSION"
    else
        echo -e "  ${YELLOW}⚠ OpenGL not available yet (reboot required)${NC}"
    fi
else
    echo "  glxinfo not available"
fi

# Check Vulkan
echo "  Checking Vulkan support..."
if command -v vulkaninfo &> /dev/null; then
    if vulkaninfo --summary &> /dev/null; then
        DEVICE_NAME=$(vulkaninfo 2>/dev/null | grep "deviceName" | head -1 || echo "Unknown")
        VULKAN_VERSION=$(vulkaninfo 2>/dev/null | grep "apiVersion" | head -1 || echo "Unknown")
        echo "  Device: $DEVICE_NAME"
        echo "  Version: $VULKAN_VERSION"
    else
        echo -e "  ${YELLOW}⚠ Vulkan not available yet (reboot required)${NC}"
    fi
else
    echo "  vulkaninfo not available"
fi

echo ""

# ============================================================================
# 6. REPORT RESULTS
# ============================================================================

echo -e "${BLUE}[6/6] Installation Summary${NC}"
echo -e "${BLUE}============================================${NC}"
echo ""

# Check if reboot is needed
NEEDS_REBOOT=false
if ! lsmod | grep -q v3d; then
    NEEDS_REBOOT=true
fi

if [ "$NEEDS_REBOOT" = true ]; then
    echo -e "${YELLOW}⚠ REBOOT REQUIRED${NC}"
    echo ""
    echo "Configuration changes have been made to $CONFIG_PATH"
    echo "You must reboot for the V3D driver to load."
    echo ""
    echo "After rebooting, run this command to verify:"
    echo "  ./check_v3d_setup.sh"
    echo ""
    echo -n "Reboot now? (y/N): "
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        echo "Rebooting..."
        reboot
    else
        echo "Please reboot manually when ready: sudo reboot"
    fi
else
    echo -e "${GREEN}✓ V3D driver stack is installed and active!${NC}"
    echo ""
    echo "Your Raspberry Pi is now optimized for GodotMark."
    echo ""
    echo "Next steps:"
    echo "  1. Build GodotMark: ./build_native_rpi5.sh template_release rpi${PI_VERSION} yes"
    echo "  2. Run benchmark: cd .. && ./Godot_v4.4-stable_linux.arm64 --path godotmark"
fi

echo ""
echo -e "${BLUE}============================================${NC}"
echo -e "${GREEN}Installation complete!${NC}"
echo -e "${BLUE}============================================${NC}"

