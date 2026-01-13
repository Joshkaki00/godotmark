#ifndef GODOTMARK_PERFORMANCE_MONITOR_H
#define GODOTMARK_PERFORMANCE_MONITOR_H

#include <array>
#include <cstdint>
#include <godot_cpp/classes/ref_counted.hpp>
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/variant/string.hpp>

using namespace godot;

class PerformanceMonitor : public RefCounted {
  GDCLASS(PerformanceMonitor, RefCounted)

 private:
  // Fixed-size circular buffers for efficiency (2 seconds @ 60fps = 120 frames)
  static constexpr size_t HISTORY_SIZE = 120;

  std::array<float, HISTORY_SIZE> fps_history;
  std::array<float, HISTORY_SIZE> frametime_history_ms;
  size_t history_index;
  size_t history_count;

  // Current frame metrics
  float current_fps;
  float current_frametime_ms;
  float delta_accumulator;
  int frame_count;

  // Statistics
  float min_fps;
  float max_fps;
  float avg_fps;
  float p1_low_fps;  // 1% low
  float p95_frametime_ms;
  float p99_frametime_ms;

  // System monitoring
  float current_temperature;
  float avg_temperature;
  float max_temperature;
  int throttle_events;

  float cpu_usage;
  float gpu_usage;

  // CPU usage tracking (Linux)
  uint64_t prev_total_cpu_time;
  uint64_t prev_idle_cpu_time;

  // Timing
  uint64_t last_update_time;
  float console_output_timer;
  static constexpr float CONSOLE_OUTPUT_INTERVAL = 1.0f;  // Output every second
  float cpu_gpu_update_timer;
  static constexpr float CPU_GPU_UPDATE_INTERVAL = 0.1f;  // Update every 100ms

  // Debug flag
  static bool verbose_logging;

  // Helper methods
  void update_statistics();
  void read_temperature();
  void read_cpu_usage();
  void detect_throttling();
  String read_file_content(const String& path);
  String read_command_output(const String& command);

 protected:
  static void _bind_methods();

 public:
  PerformanceMonitor();
  ~PerformanceMonitor();

  // Debug control
  void set_verbose_logging(bool enabled);
  bool get_verbose_logging() const;

  // Update method (call every frame)
  void update(float delta);

  // Getters - Current values
  float get_current_fps() const;
  float get_current_frametime_ms() const;
  float get_temperature() const;
  float get_cpu_usage() const;
  float get_gpu_usage() const;

  // Getters - Statistics
  float get_avg_fps() const;
  float get_min_fps() const;
  float get_max_fps() const;
  float get_p1_low_fps() const;
  float get_p95_frametime_ms() const;
  float get_p99_frametime_ms() const;

  // Getters - Thermal
  float get_avg_temperature() const;
  float get_max_temperature() const;
  int get_throttle_events() const;
  bool is_throttling() const;

  // Formatted output for console
  String get_performance_summary() const;

  // Reset statistics
  void reset();
};

#endif  // GODOTMARK_PERFORMANCE_MONITOR_H
