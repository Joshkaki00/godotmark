#ifndef GODOTMARK_ADAPTIVE_QUALITY_MANAGER_H
#define GODOTMARK_ADAPTIVE_QUALITY_MANAGER_H

#include <godot_cpp/classes/ref_counted.hpp>
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/variant/string.hpp>

using namespace godot;

class AdaptiveQualityManager : public RefCounted {
    GDCLASS(AdaptiveQualityManager, RefCounted)

public:
    enum QualityPreset {
        POTATO = 0,
        LOW = 1,
        MEDIUM = 2,
        HIGH = 3,
        ULTRA = 4
    };

private:
    QualityPreset current_preset;
    
    // Performance thresholds
    static constexpr float TARGET_FPS = 30.0f;
    static constexpr float MIN_FPS = 25.0f;         // Downgrade below this
    static constexpr float UPGRADE_FPS = 33.0f;     // Upgrade above this (slightly above target)
    static constexpr float TEMP_THROTTLE_THRESHOLD = 75.0f;
    
    // Hysteresis time-based (prevent rapid switching)
    float time_below_target;
    float time_above_target;
    static constexpr float DOWNGRADE_TIME = 2.0f;   // 2 seconds below MIN_FPS
    static constexpr float UPGRADE_TIME = 3.0f;     // 3 seconds above UPGRADE_FPS
    
    // Debug flag
    static bool verbose_logging;
    
    // Quality settings for each preset
    struct QualitySettings {
        int texture_resolution;      // 512, 1024, 2048, 4096
        bool shadows_enabled;
        int shadow_quality;          // 0-3
        int particle_count;
        int physics_bodies;
        bool post_processing;
        String name;
    };
    
    QualitySettings presets[5];
    
    void initialize_presets();
    void apply_preset_internal(QualityPreset preset);

protected:
    static void _bind_methods();

public:
    AdaptiveQualityManager();
    ~AdaptiveQualityManager();
    
    // Initialize with starting preset
    void initialize(int starting_preset = MEDIUM);
    
    // Debug control
    void set_verbose_logging(bool enabled);
    bool get_verbose_logging() const;
    
    // Update based on performance (call every frame)
    void update(float current_fps, float temperature);
    
    // Manual quality control
    void set_quality_preset(int preset);
    int get_quality_preset() const;
    String get_quality_name() const;
    
    // Quality settings getters
    int get_texture_resolution() const;
    bool get_shadows_enabled() const;
    int get_shadow_quality() const;
    int get_particle_count() const;
    int get_physics_bodies() const;
    bool get_post_processing() const;
    
    // Status
    bool can_upgrade() const;
    bool can_downgrade() const;
    String get_status() const;
    
    // Reset counters
    void reset_hysteresis();
};

VARIANT_ENUM_CAST(AdaptiveQualityManager::QualityPreset);

#endif // GODOTMARK_ADAPTIVE_QUALITY_MANAGER_H

