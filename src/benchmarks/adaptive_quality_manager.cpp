#include "adaptive_quality_manager.h"

#include <godot_cpp/variant/utility_functions.hpp>

bool AdaptiveQualityManager::verbose_logging = false;

AdaptiveQualityManager::AdaptiveQualityManager()
    : current_preset(MEDIUM), time_below_target(0.0f), time_above_target(0.0f) {
  initialize_presets();
}

AdaptiveQualityManager::~AdaptiveQualityManager() {}

void AdaptiveQualityManager::_bind_methods() {
  ClassDB::bind_method(D_METHOD("initialize", "starting_preset"),
                       &AdaptiveQualityManager::initialize, DEFVAL(MEDIUM));
  ClassDB::bind_method(D_METHOD("update", "current_fps", "temperature"),
                       &AdaptiveQualityManager::update);
  ClassDB::bind_method(D_METHOD("set_verbose_logging", "enabled"),
                       &AdaptiveQualityManager::set_verbose_logging);
  ClassDB::bind_method(D_METHOD("get_verbose_logging"),
                       &AdaptiveQualityManager::get_verbose_logging);

  ClassDB::bind_method(D_METHOD("set_quality_preset", "preset"),
                       &AdaptiveQualityManager::set_quality_preset);
  ClassDB::bind_method(D_METHOD("get_quality_preset"),
                       &AdaptiveQualityManager::get_quality_preset);
  ClassDB::bind_method(D_METHOD("get_quality_name"),
                       &AdaptiveQualityManager::get_quality_name);

  ClassDB::bind_method(D_METHOD("get_texture_resolution"),
                       &AdaptiveQualityManager::get_texture_resolution);
  ClassDB::bind_method(D_METHOD("get_shadows_enabled"),
                       &AdaptiveQualityManager::get_shadows_enabled);
  ClassDB::bind_method(D_METHOD("get_shadow_quality"),
                       &AdaptiveQualityManager::get_shadow_quality);
  ClassDB::bind_method(D_METHOD("get_particle_count"),
                       &AdaptiveQualityManager::get_particle_count);
  ClassDB::bind_method(D_METHOD("get_physics_bodies"),
                       &AdaptiveQualityManager::get_physics_bodies);
  ClassDB::bind_method(D_METHOD("get_post_processing"),
                       &AdaptiveQualityManager::get_post_processing);

  ClassDB::bind_method(D_METHOD("can_upgrade"),
                       &AdaptiveQualityManager::can_upgrade);
  ClassDB::bind_method(D_METHOD("can_downgrade"),
                       &AdaptiveQualityManager::can_downgrade);
  ClassDB::bind_method(D_METHOD("get_status"),
                       &AdaptiveQualityManager::get_status);
  ClassDB::bind_method(D_METHOD("reset_hysteresis"),
                       &AdaptiveQualityManager::reset_hysteresis);

  // Bind enum
  BIND_ENUM_CONSTANT(POTATO);
  BIND_ENUM_CONSTANT(LOW);
  BIND_ENUM_CONSTANT(MEDIUM);
  BIND_ENUM_CONSTANT(HIGH);
  BIND_ENUM_CONSTANT(ULTRA);
}

void AdaptiveQualityManager::set_verbose_logging(bool enabled) {
  verbose_logging = enabled;
}

bool AdaptiveQualityManager::get_verbose_logging() const {
  return verbose_logging;
}

void AdaptiveQualityManager::initialize_presets() {
  // Potato - Absolute minimum for 2GB RPi4
  presets[POTATO] = {
      512,      // texture_resolution
      false,    // shadows_enabled
      0,        // shadow_quality
      100,      // particle_count
      50,       // physics_bodies
      false,    // post_processing
      "Potato"  // name
  };

  // Low - Minimum playable for 4GB RPi4
  presets[LOW] = {
      1024,   // texture_resolution
      true,   // shadows_enabled
      1,      // shadow_quality
      500,    // particle_count
      200,    // physics_bodies
      false,  // post_processing
      "Low"   // name
  };

  // Medium - Balanced for RPi5 / Orange Pi 5
  presets[MEDIUM] = {
      2048,     // texture_resolution
      true,     // shadows_enabled
      2,        // shadow_quality
      2000,     // particle_count
      500,      // physics_bodies
      true,     // post_processing
      "Medium"  // name
  };

  // High - For high-end SBCs
  presets[HIGH] = {
      2048,   // texture_resolution
      true,   // shadows_enabled
      3,      // shadow_quality
      5000,   // particle_count
      1000,   // physics_bodies
      true,   // post_processing
      "High"  // name
  };

  // Ultra - Maximum quality (Jetson Orin)
  presets[ULTRA] = {
      4096,    // texture_resolution
      true,    // shadows_enabled
      3,       // shadow_quality
      10000,   // particle_count
      2000,    // physics_bodies
      true,    // post_processing
      "Ultra"  // name
  };
}

void AdaptiveQualityManager::initialize(int starting_preset) {
  if (starting_preset >= POTATO && starting_preset <= ULTRA) {
    current_preset = static_cast<QualityPreset>(starting_preset);
  } else {
    current_preset = MEDIUM;
  }

  time_below_target = 0.0f;
  time_above_target = 0.0f;

  apply_preset_internal(current_preset);

  UtilityFunctions::print("[AdaptiveQuality] Initialized at: ",
                          get_quality_name());
}

void AdaptiveQualityManager::update(float current_fps, float temperature) {
  // Get delta time from Engine (this is called every frame)
  // We'll approximate delta as 1/current_fps for time tracking
  float delta = (current_fps > 0) ? (1.0f / current_fps) : 0.016f;

  // Immediate downgrade on thermal throttling
  if (temperature > TEMP_THROTTLE_THRESHOLD) {
    if (can_downgrade()) {
      if (verbose_logging) {
        UtilityFunctions::print(
            "[AdaptiveQuality] Temperature ", String::num(temperature, 1),
            "°C → Downgrading to ",
            presets[current_preset - 1].name.utf8().get_data());
      } else {
        UtilityFunctions::print(
            "[AdaptiveQuality] Thermal throttle → ",
            presets[current_preset - 1].name.utf8().get_data());
      }
      set_quality_preset(current_preset - 1);
      reset_hysteresis();
    }
    return;
  }

  // Track performance over time (not frames)
  if (current_fps < MIN_FPS) {
    time_below_target += delta;
    time_above_target = 0.0f;

    if (verbose_logging && time_below_target > 0.5f) {
      UtilityFunctions::print("[AdaptiveQuality] Below target for ",
                              String::num(time_below_target, 1),
                              "s (FPS: ", String::num(current_fps, 1), ")");
    }
  } else if (current_fps > UPGRADE_FPS) {
    time_above_target += delta;
    time_below_target = 0.0f;

    if (verbose_logging && time_above_target > 1.0f &&
        (int(time_above_target * 10) % 10 == 0)) {
      UtilityFunctions::print("[AdaptiveQuality] Above target for ",
                              String::num(time_above_target, 1),
                              "s (FPS: ", String::num(current_fps, 1), ")");
    }
  } else {
    // In acceptable range (MIN_FPS <= fps <= UPGRADE_FPS), decay timers slowly
    time_below_target = MAX(0.0f, time_below_target - delta * 0.5f);
    time_above_target = MAX(0.0f, time_above_target - delta * 0.5f);
  }

  // Adaptive scaling with time-based hysteresis
  if (time_below_target >= DOWNGRADE_TIME) {
    if (can_downgrade()) {
      UtilityFunctions::print(
          "[AdaptiveQuality] FPS below ", String::num(MIN_FPS, 1), " for ",
          String::num(time_below_target, 1), "s → Downgrading to ",
          presets[current_preset - 1].name.utf8().get_data());
      set_quality_preset(current_preset - 1);
      reset_hysteresis();
    }
  } else if (time_above_target >= UPGRADE_TIME) {
    if (can_upgrade()) {
      UtilityFunctions::print(
          "[AdaptiveQuality] FPS above ", String::num(UPGRADE_FPS, 1), " for ",
          String::num(time_above_target, 1), "s → Upgrading to ",
          presets[current_preset + 1].name.utf8().get_data());
      set_quality_preset(current_preset + 1);
      reset_hysteresis();
    }
  }
}

void AdaptiveQualityManager::set_quality_preset(int preset) {
  if (preset < POTATO || preset > ULTRA) {
    UtilityFunctions::push_warning("[AdaptiveQuality] Invalid preset: ",
                                   preset);
    return;
  }

  current_preset = static_cast<QualityPreset>(preset);
  apply_preset_internal(current_preset);
}

void AdaptiveQualityManager::apply_preset_internal(QualityPreset preset) {
  // This is where we would actually apply the settings to the rendering system
  // For now, we just store the current preset
  // In a real implementation, this would call RenderingServer methods

  const QualitySettings& settings = presets[preset];

  UtilityFunctions::print("[AdaptiveQuality] Applied preset: ",
                          settings.name.utf8().get_data());
  UtilityFunctions::print("  Texture Resolution: ",
                          settings.texture_resolution);
  UtilityFunctions::print("  Shadows: ",
                          settings.shadows_enabled ? "Enabled" : "Disabled");
  UtilityFunctions::print("  Shadow Quality: ", settings.shadow_quality);
  UtilityFunctions::print("  Particle Count: ", settings.particle_count);
  UtilityFunctions::print("  Physics Bodies: ", settings.physics_bodies);
  UtilityFunctions::print("  Post Processing: ",
                          settings.post_processing ? "Enabled" : "Disabled");
}

int AdaptiveQualityManager::get_quality_preset() const {
  return static_cast<int>(current_preset);
}

String AdaptiveQualityManager::get_quality_name() const {
  return presets[current_preset].name;
}

int AdaptiveQualityManager::get_texture_resolution() const {
  return presets[current_preset].texture_resolution;
}

bool AdaptiveQualityManager::get_shadows_enabled() const {
  return presets[current_preset].shadows_enabled;
}

int AdaptiveQualityManager::get_shadow_quality() const {
  return presets[current_preset].shadow_quality;
}

int AdaptiveQualityManager::get_particle_count() const {
  return presets[current_preset].particle_count;
}

int AdaptiveQualityManager::get_physics_bodies() const {
  return presets[current_preset].physics_bodies;
}

bool AdaptiveQualityManager::get_post_processing() const {
  return presets[current_preset].post_processing;
}

bool AdaptiveQualityManager::can_upgrade() const {
  return current_preset < ULTRA;
}

bool AdaptiveQualityManager::can_downgrade() const {
  return current_preset > POTATO;
}

String AdaptiveQualityManager::get_status() const {
  String status = "Quality: " + get_quality_name();
  status += " | ";

  if (time_below_target > DOWNGRADE_TIME / 2) {
    status += "⚠️ Low FPS (" + String::num(time_below_target, 1) + "s)";
  } else if (time_above_target > UPGRADE_TIME / 2) {
    status += "✓ Good performance (" + String::num(time_above_target, 1) + "s)";
  } else {
    status += "Stable";
  }

  return status;
}

void AdaptiveQualityManager::reset_hysteresis() {
  time_below_target = 0.0f;
  time_above_target = 0.0f;
}
