#ifndef GODOTMARK_PLATFORM_DETECTOR_H
#define GODOTMARK_PLATFORM_DETECTOR_H

#include <godot_cpp/classes/ref_counted.hpp>
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/variant/string.hpp>

using namespace godot;

class PlatformDetector : public RefCounted {
    GDCLASS(PlatformDetector, RefCounted)

private:
    // System information (fixed-size for efficiency)
    String platform_name;
    String cpu_model;
    String gpu_vendor;
    int cpu_core_count;
    int ram_mb;
    float cpu_freq_mhz;
    bool vulkan_supported;
    String vulkan_version;
    
    // Debug flag
    static bool verbose_logging;
    
    // Detection methods
    void detect_platform();
    void detect_cpu();
    void detect_gpu();
    void detect_memory();
    void detect_vulkan();
    
    // Platform-specific helpers
    String read_file_content(const String& path);
    String detect_raspberry_pi();
    String detect_orange_pi();
    String detect_jetson();

protected:
    static void _bind_methods();

public:
    PlatformDetector();
    ~PlatformDetector();
    
    // Initialize detection
    void initialize();
    
    // Debug control
    void set_verbose_logging(bool enabled);
    bool get_verbose_logging() const;
    
    // Getters (formatted strings for UI)
    String get_platform_name() const;
    String get_cpu_model() const;
    int get_cpu_core_count() const;
    int get_ram_mb() const;
    float get_cpu_freq_mhz() const;
    String get_gpu_vendor() const;
    bool is_vulkan_supported() const;
    String get_vulkan_version() const;
    
    // Formatted output for console
    String get_system_info_formatted() const;
    
    // Platform checks
    bool is_raspberry_pi() const;
    bool is_raspberry_pi_4() const;
    bool is_raspberry_pi_5() const;
    bool is_orange_pi() const;
    bool is_jetson() const;
    bool is_arm64() const;
};

#endif // GODOTMARK_PLATFORM_DETECTOR_H

