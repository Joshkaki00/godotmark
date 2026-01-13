#include "platform_detector.h"

#include <fstream>
#include <godot_cpp/classes/os.hpp>
#include <godot_cpp/classes/rendering_server.hpp>
#include <godot_cpp/variant/utility_functions.hpp>
#include <sstream>
#include <string>

bool PlatformDetector::verbose_logging = false;

PlatformDetector::PlatformDetector()
    : platform_name("Unknown"),
      cpu_model("Unknown"),
      gpu_vendor("Unknown"),
      cpu_core_count(0),
      ram_mb(0),
      cpu_freq_mhz(0.0f),
      vulkan_supported(false),
      vulkan_version("Unknown") {}

PlatformDetector::~PlatformDetector() {}

void PlatformDetector::_bind_methods() {
  ClassDB::bind_method(D_METHOD("initialize"), &PlatformDetector::initialize);
  ClassDB::bind_method(D_METHOD("set_verbose_logging", "enabled"),
                       &PlatformDetector::set_verbose_logging);
  ClassDB::bind_method(D_METHOD("get_verbose_logging"),
                       &PlatformDetector::get_verbose_logging);

  ClassDB::bind_method(D_METHOD("get_platform_name"),
                       &PlatformDetector::get_platform_name);
  ClassDB::bind_method(D_METHOD("get_cpu_model"),
                       &PlatformDetector::get_cpu_model);
  ClassDB::bind_method(D_METHOD("get_cpu_core_count"),
                       &PlatformDetector::get_cpu_core_count);
  ClassDB::bind_method(D_METHOD("get_ram_mb"), &PlatformDetector::get_ram_mb);
  ClassDB::bind_method(D_METHOD("get_cpu_freq_mhz"),
                       &PlatformDetector::get_cpu_freq_mhz);
  ClassDB::bind_method(D_METHOD("get_gpu_vendor"),
                       &PlatformDetector::get_gpu_vendor);
  ClassDB::bind_method(D_METHOD("is_vulkan_supported"),
                       &PlatformDetector::is_vulkan_supported);
  ClassDB::bind_method(D_METHOD("get_vulkan_version"),
                       &PlatformDetector::get_vulkan_version);
  ClassDB::bind_method(D_METHOD("get_system_info_formatted"),
                       &PlatformDetector::get_system_info_formatted);

  ClassDB::bind_method(D_METHOD("is_raspberry_pi"),
                       &PlatformDetector::is_raspberry_pi);
  ClassDB::bind_method(D_METHOD("is_raspberry_pi_4"),
                       &PlatformDetector::is_raspberry_pi_4);
  ClassDB::bind_method(D_METHOD("is_raspberry_pi_5"),
                       &PlatformDetector::is_raspberry_pi_5);
  ClassDB::bind_method(D_METHOD("is_orange_pi"),
                       &PlatformDetector::is_orange_pi);
  ClassDB::bind_method(D_METHOD("is_jetson"), &PlatformDetector::is_jetson);
  ClassDB::bind_method(D_METHOD("is_arm64"), &PlatformDetector::is_arm64);

  ClassDB::bind_method(D_METHOD("is_v3d_driver_loaded"),
                       &PlatformDetector::is_v3d_driver_loaded);
  ClassDB::bind_method(D_METHOD("is_v3d_config_enabled"),
                       &PlatformDetector::is_v3d_config_enabled);
  ClassDB::bind_method(D_METHOD("is_vulkan_driver_available"),
                       &PlatformDetector::is_vulkan_driver_available);
  ClassDB::bind_method(D_METHOD("get_mesa_version"),
                       &PlatformDetector::get_mesa_version);
  ClassDB::bind_method(D_METHOD("get_driver_status_summary"),
                       &PlatformDetector::get_driver_status_summary);
}

void PlatformDetector::set_verbose_logging(bool enabled) {
  verbose_logging = enabled;
}

bool PlatformDetector::get_verbose_logging() const { return verbose_logging; }

void PlatformDetector::initialize() {
  UtilityFunctions::print("[PlatformDetector] Initializing...");

  if (verbose_logging) {
    UtilityFunctions::print("[Verbose] Starting platform detection");
  }

  detect_platform();
  detect_cpu();
  detect_memory();
  detect_gpu();
  detect_vulkan();

  if (verbose_logging) {
    UtilityFunctions::print("[Verbose] Platform detection complete");
  }

  // Print formatted system info to console
  UtilityFunctions::print(get_system_info_formatted());
}

String PlatformDetector::read_file_content(const String& path) const {
#ifdef __linux__
  std::ifstream file(path.utf8().get_data());
  if (!file.is_open()) {
    return "";
  }

  std::stringstream buffer;
  buffer << file.rdbuf();
  return String(buffer.str().c_str());
#else
  return "";
#endif
}

String PlatformDetector::detect_raspberry_pi() {
#ifdef __linux__
  // Check /proc/cpuinfo for Raspberry Pi
  String cpuinfo = read_file_content("/proc/cpuinfo");
  if (cpuinfo.contains("Raspberry Pi")) {
    if (cpuinfo.contains("Raspberry Pi 5")) {
      return "Raspberry Pi 5";
    } else if (cpuinfo.contains("Raspberry Pi 4")) {
      return "Raspberry Pi 4 Model B";
    } else if (cpuinfo.contains("Raspberry Pi 3")) {
      return "Raspberry Pi 3";
    }
    return "Raspberry Pi";
  }

  // Check /proc/device-tree/model
  String model = read_file_content("/proc/device-tree/model");
  if (model.contains("Raspberry Pi")) {
    return model.strip_edges();
  }
#endif
  return "";
}

String PlatformDetector::detect_orange_pi() {
#ifdef __linux__
  String model = read_file_content("/proc/device-tree/model");
  if (model.contains("Orange Pi")) {
    return model.strip_edges();
  }
#endif
  return "";
}

String PlatformDetector::detect_jetson() {
#ifdef __linux__
  String model = read_file_content("/proc/device-tree/model");
  if (model.contains("Jetson") || model.contains("NVIDIA")) {
    return model.strip_edges();
  }

  // Check for Jetson-specific files
  String jetson_release = read_file_content("/etc/nv_tegra_release");
  if (!jetson_release.is_empty()) {
    return "NVIDIA Jetson";
  }
#endif
  return "";
}

void PlatformDetector::detect_platform() {
  OS* os = OS::get_singleton();
  String os_name = os->get_name();

  // Try specific platform detection
  String rpi = detect_raspberry_pi();
  if (!rpi.is_empty()) {
    platform_name = rpi;
    return;
  }

  String opi = detect_orange_pi();
  if (!opi.is_empty()) {
    platform_name = opi;
    return;
  }

  String jetson = detect_jetson();
  if (!jetson.is_empty()) {
    platform_name = jetson;
    return;
  }

  // Fallback to OS name
  platform_name = os_name;
}

void PlatformDetector::detect_cpu() {
  OS* os = OS::get_singleton();
  cpu_core_count = os->get_processor_count();

#ifdef __linux__
  // Read /proc/cpuinfo for CPU model
  String cpuinfo = read_file_content("/proc/cpuinfo");

  // Parse CPU model
  if (cpuinfo.contains("model name")) {
    int start = cpuinfo.find("model name");
    int colon = cpuinfo.find(":", start);
    int newline = cpuinfo.find("\n", colon);
    if (colon > 0 && newline > colon) {
      cpu_model = cpuinfo.substr(colon + 1, newline - colon - 1).strip_edges();
    }
  } else if (cpuinfo.contains("Hardware")) {
    // ARM-specific (Raspberry Pi, etc.)
    int start = cpuinfo.find("Hardware");
    int colon = cpuinfo.find(":", start);
    int newline = cpuinfo.find("\n", colon);
    if (colon > 0 && newline > colon) {
      cpu_model = cpuinfo.substr(colon + 1, newline - colon - 1).strip_edges();
    }
  }

  // Detect ARM Cortex models
  if (cpuinfo.contains("Cortex-A72")) {
    cpu_model = "ARM Cortex-A72";
  } else if (cpuinfo.contains("Cortex-A76")) {
    cpu_model = "ARM Cortex-A76";
  } else if (cpuinfo.contains("Cortex-A53")) {
    cpu_model = "ARM Cortex-A53";
  }

  // Try to get CPU frequency
  String cpufreq = read_file_content(
      "/sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq");
  if (!cpufreq.is_empty()) {
    cpu_freq_mhz = cpufreq.to_float() / 1000.0f;  // Convert kHz to MHz
  }
#elif defined(_WIN32)
  cpu_model = "x86_64";
  // On Windows, we can't easily get detailed CPU info without WMI
#endif

  if (cpu_model.is_empty()) {
    cpu_model = "Unknown CPU";
  }
}

void PlatformDetector::detect_memory() {
#ifdef __linux__
  // Read /proc/meminfo
  String meminfo = read_file_content("/proc/meminfo");
  if (meminfo.contains("MemTotal")) {
    int start = meminfo.find("MemTotal");
    int colon = meminfo.find(":", start);
    int newline = meminfo.find("\n", colon);
    if (colon > 0 && newline > colon) {
      String mem_str =
          meminfo.substr(colon + 1, newline - colon - 1).strip_edges();
      // MemTotal is in kB, convert to MB
      ram_mb = mem_str.to_int() / 1024;
    }
  }
#elif defined(_WIN32)
  // On Windows, use Godot's OS API
  OS* os = OS::get_singleton();
  // Note: Godot doesn't expose total RAM directly, this is a placeholder
  ram_mb = 8192;  // Default assumption for Windows
#endif
}

void PlatformDetector::detect_gpu() {
  RenderingServer* rs = RenderingServer::get_singleton();
  if (rs) {
    gpu_vendor = rs->get_video_adapter_name();
  }

  if (gpu_vendor.is_empty()) {
    gpu_vendor = "Unknown GPU";
  }
}

void PlatformDetector::detect_vulkan() {
  // Godot 4.x uses Vulkan by default on supported platforms
  // We'll assume Vulkan is supported if RenderingServer is available
  RenderingServer* rs = RenderingServer::get_singleton();
  vulkan_supported = (rs != nullptr);

  if (vulkan_supported) {
    vulkan_version = "Vulkan 1.2+";
  }

#ifdef __linux__
  // On Linux, check for vulkaninfo command
  // This is a placeholder - actual implementation would need system calls
  vulkan_version = "Vulkan 1.2+";
#endif
}

// Getters
String PlatformDetector::get_platform_name() const { return platform_name; }

String PlatformDetector::get_cpu_model() const { return cpu_model; }

int PlatformDetector::get_cpu_core_count() const { return cpu_core_count; }

int PlatformDetector::get_ram_mb() const { return ram_mb; }

float PlatformDetector::get_cpu_freq_mhz() const { return cpu_freq_mhz; }

String PlatformDetector::get_gpu_vendor() const { return gpu_vendor; }

bool PlatformDetector::is_vulkan_supported() const { return vulkan_supported; }

String PlatformDetector::get_vulkan_version() const { return vulkan_version; }

String PlatformDetector::get_system_info_formatted() const {
  String output = "\n";
  output += "========================================\n";
  output += "GodotMark System Information\n";
  output += "========================================\n";
  output += "Platform: " + platform_name + "\n";
  output +=
      "CPU: " + cpu_model + " (" + String::num_int64(cpu_core_count) + " cores";
  if (cpu_freq_mhz > 0) {
    output += " @ " + String::num(cpu_freq_mhz / 1000.0f, 2) + " GHz";
  }
  output += ")\n";
  output += "RAM: " + String::num_int64(ram_mb) + " MB\n";
  output += "GPU: " + gpu_vendor + "\n";
  output +=
      "Vulkan: " + (vulkan_supported ? vulkan_version : "Not supported") + "\n";
  output += "========================================\n";
  return output;
}

// Platform checks
bool PlatformDetector::is_raspberry_pi() const {
  return platform_name.contains("Raspberry Pi");
}

bool PlatformDetector::is_raspberry_pi_4() const {
  return platform_name.contains("Raspberry Pi 4");
}

bool PlatformDetector::is_raspberry_pi_5() const {
  return platform_name.contains("Raspberry Pi 5");
}

bool PlatformDetector::is_orange_pi() const {
  return platform_name.contains("Orange Pi");
}

bool PlatformDetector::is_jetson() const {
  return platform_name.contains("Jetson") || platform_name.contains("NVIDIA");
}

bool PlatformDetector::is_arm64() const {
#ifdef __aarch64__
  return true;
#else
  return cpu_model.contains("ARM") || cpu_model.contains("Cortex");
#endif
}

// V3D driver checks
bool PlatformDetector::is_v3d_driver_loaded() const {
#ifdef __linux__
  // Check if v3d kernel module is loaded
  String lsmod_check = read_file_content("/proc/modules");
  if (lsmod_check.contains("v3d")) {
    if (verbose_logging) {
      UtilityFunctions::print("[Verbose] V3D module found in /proc/modules");
    }
    return true;
  }

  // Alternative: Check if DRI device exists
  std::ifstream dri_device("/dev/dri/renderD128");
  if (dri_device.good()) {
    if (verbose_logging) {
      UtilityFunctions::print("[Verbose] DRI render device found");
    }
    return true;
  }

  if (verbose_logging) {
    UtilityFunctions::print("[Verbose] V3D module not loaded");
  }
  return false;
#else
  return false;
#endif
}

bool PlatformDetector::is_v3d_config_enabled() const {
#ifdef __linux__
  // Check /boot/config.txt or /boot/firmware/config.txt
  String config_content = read_file_content("/boot/firmware/config.txt");
  if (config_content.is_empty()) {
    config_content = read_file_content("/boot/config.txt");
  }

  if (config_content.is_empty()) {
    if (verbose_logging) {
      UtilityFunctions::print("[Verbose] Could not read config.txt");
    }
    return false;
  }

  // Check for uncommented dtoverlay=vc4-kms-v3d
  bool enabled = config_content.contains("dtoverlay=vc4-kms-v3d") &&
                 !config_content.contains("#dtoverlay=vc4-kms-v3d");

  if (verbose_logging) {
    UtilityFunctions::print(String("[Verbose] V3D config enabled: ") +
                            (enabled ? "yes" : "no"));
  }

  return enabled;
#else
  return false;
#endif
}

bool PlatformDetector::is_vulkan_driver_available() const {
#ifdef __linux__
  // Check if Vulkan loader library exists
  std::ifstream vulkan_lib("/usr/lib/aarch64-linux-gnu/libvulkan.so.1");
  if (vulkan_lib.good()) {
    if (verbose_logging) {
      UtilityFunctions::print("[Verbose] Vulkan library found");
    }
    return true;
  }

  // Alternative path for x86_64
  std::ifstream vulkan_lib_x86("/usr/lib/x86_64-linux-gnu/libvulkan.so.1");
  if (vulkan_lib_x86.good()) {
    if (verbose_logging) {
      UtilityFunctions::print("[Verbose] Vulkan library found (x86_64)");
    }
    return true;
  }

  if (verbose_logging) {
    UtilityFunctions::print("[Verbose] Vulkan library not found");
  }
  return false;
#else
  return vulkan_supported;
#endif
}

String PlatformDetector::get_mesa_version() const {
#ifdef __linux__
  // Try to read mesa version from dpkg
  String dpkg_output = read_file_content("/var/lib/dpkg/status");

  if (dpkg_output.contains("mesa-vulkan-drivers")) {
    int pkg_start = dpkg_output.find("Package: mesa-vulkan-drivers");
    if (pkg_start >= 0) {
      int version_start = dpkg_output.find("Version:", pkg_start);
      if (version_start >= 0) {
        int colon = dpkg_output.find(":", version_start);
        int newline = dpkg_output.find("\n", colon);
        if (colon > 0 && newline > colon) {
          String version =
              dpkg_output.substr(colon + 1, newline - colon - 1).strip_edges();
          if (verbose_logging) {
            UtilityFunctions::print("[Verbose] Mesa version: " + version);
          }
          return version;
        }
      }
    }
  }

  if (verbose_logging) {
    UtilityFunctions::print("[Verbose] Could not determine Mesa version");
  }
  return "Unknown";
#else
  return "N/A";
#endif
}

String PlatformDetector::get_driver_status_summary() const {
  String summary = "\n";
  summary += "========================================\n";
  summary += "Driver Status Summary\n";
  summary += "========================================\n";

  if (!is_raspberry_pi()) {
    summary += "Not a Raspberry Pi - driver checks not applicable\n";
    summary += "========================================\n";
    return summary;
  }

  bool v3d_loaded = is_v3d_driver_loaded();
  bool v3d_config = is_v3d_config_enabled();
  bool vulkan_avail = is_vulkan_driver_available();
  String mesa_ver = get_mesa_version();

  summary += "V3D Config Enabled: " + String(v3d_config ? "YES" : "NO") + "\n";
  summary += "V3D Driver Loaded: " + String(v3d_loaded ? "YES" : "NO") + "\n";
  summary += "Vulkan Available: " + String(vulkan_avail ? "YES" : "NO") + "\n";
  summary += "Mesa Version: " + mesa_ver + "\n";
  summary += "========================================\n";

  if (!v3d_config || !v3d_loaded || !vulkan_avail) {
    summary += "\n";
    summary += "[WARNING] Driver stack not fully configured!\n";
    summary += "For optimal performance, run:\n";
    summary += "  cd godotmark\n";
    summary += "  sudo ./install_v3d_stack.sh\n";
    summary += "========================================\n";
  } else {
    summary += "\n";
    summary += "[OK] Driver stack properly configured!\n";
    summary += "========================================\n";
  }

  return summary;
}
