#ifndef GODOTMARK_RESULTS_EXPORTER_H
#define GODOTMARK_RESULTS_EXPORTER_H

#include <godot_cpp/classes/ref_counted.hpp>
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/variant/dictionary.hpp>
#include <godot_cpp/variant/string.hpp>

using namespace godot;

class ResultsExporter : public RefCounted {
  GDCLASS(ResultsExporter, RefCounted)

 private:
  // Platform info
  String platform_name;
  String cpu_model;
  int ram_mb;
  String gpu_info;

  // Scene info
  String scene_name;
  float duration_seconds;

  // Performance data
  float avg_fps;
  float min_fps;
  float max_fps;
  float p1_low_fps;
  float p95_frametime_ms;
  float p99_frametime_ms;

  // Thermal data
  float avg_temperature;
  float max_temperature;
  int throttle_events;

  // Load/Quality data
  int triangle_count;
  String quality_preset;
  int draw_calls;
  float vram_usage_mb;

 protected:
  static void _bind_methods();

 public:
  ResultsExporter();
  ~ResultsExporter();

  // Setters
  void set_platform_info(const String& platform, const String& cpu, int ram);
  void set_gpu_info(const String& gpu);
  void set_scene_info(const String& scene, float duration);
  void set_performance_data(float avg, float min, float p1_low,
                            float p95_frame);
  void set_performance_extended(float max, float p99_frame);
  void set_thermal_data(float avg_temp, float max_temp, int throttle);
  void set_load_data(int triangles, const String& quality);
  void set_draw_calls(int calls);
  void set_vram_usage(float mb);

  // Getters
  String get_platform_name() const;
  String get_cpu_model() const;
  int get_ram_mb() const;
  float get_avg_fps() const;
  float get_min_fps() const;

  // Export functions
  Dictionary to_dictionary() const;
  String to_json_string() const;
  void print_console() const;
  bool save_json(const String& filepath);
};

#endif  // GODOTMARK_RESULTS_EXPORTER_H
