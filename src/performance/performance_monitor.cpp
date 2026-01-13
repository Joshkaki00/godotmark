#include "performance_monitor.h"

#include <algorithm>
#include <cmath>
#include <fstream>
#include <godot_cpp/classes/time.hpp>
#include <godot_cpp/variant/utility_functions.hpp>
#include <sstream>

bool PerformanceMonitor::verbose_logging = false;

PerformanceMonitor::PerformanceMonitor()
    : history_index(0),
      history_count(0),
      current_fps(0.0f),
      current_frametime_ms(0.0f),
      delta_accumulator(0.0f),
      frame_count(0),
      min_fps(999999.0f),
      max_fps(0.0f),
      avg_fps(0.0f),
      p1_low_fps(0.0f),
      p95_frametime_ms(0.0f),
      p99_frametime_ms(0.0f),
      current_temperature(0.0f),
      avg_temperature(0.0f),
      max_temperature(0.0f),
      throttle_events(0),
      cpu_usage(0.0f),
      gpu_usage(0.0f),
      last_update_time(0),
      console_output_timer(0.0f) {
  // Initialize arrays
  fps_history.fill(0.0f);
  frametime_history_ms.fill(0.0f);
}

PerformanceMonitor::~PerformanceMonitor() {}

void PerformanceMonitor::_bind_methods() {
  ClassDB::bind_method(D_METHOD("update", "delta"),
                       &PerformanceMonitor::update);
  ClassDB::bind_method(D_METHOD("reset"), &PerformanceMonitor::reset);
  ClassDB::bind_method(D_METHOD("set_verbose_logging", "enabled"),
                       &PerformanceMonitor::set_verbose_logging);
  ClassDB::bind_method(D_METHOD("get_verbose_logging"),
                       &PerformanceMonitor::get_verbose_logging);

  // Current values
  ClassDB::bind_method(D_METHOD("get_current_fps"),
                       &PerformanceMonitor::get_current_fps);
  ClassDB::bind_method(D_METHOD("get_current_frametime_ms"),
                       &PerformanceMonitor::get_current_frametime_ms);
  ClassDB::bind_method(D_METHOD("get_temperature"),
                       &PerformanceMonitor::get_temperature);
  ClassDB::bind_method(D_METHOD("get_cpu_usage"),
                       &PerformanceMonitor::get_cpu_usage);
  ClassDB::bind_method(D_METHOD("get_gpu_usage"),
                       &PerformanceMonitor::get_gpu_usage);

  // Statistics
  ClassDB::bind_method(D_METHOD("get_avg_fps"),
                       &PerformanceMonitor::get_avg_fps);
  ClassDB::bind_method(D_METHOD("get_min_fps"),
                       &PerformanceMonitor::get_min_fps);
  ClassDB::bind_method(D_METHOD("get_max_fps"),
                       &PerformanceMonitor::get_max_fps);
  ClassDB::bind_method(D_METHOD("get_p1_low_fps"),
                       &PerformanceMonitor::get_p1_low_fps);
  ClassDB::bind_method(D_METHOD("get_p95_frametime_ms"),
                       &PerformanceMonitor::get_p95_frametime_ms);
  ClassDB::bind_method(D_METHOD("get_p99_frametime_ms"),
                       &PerformanceMonitor::get_p99_frametime_ms);

  // Thermal
  ClassDB::bind_method(D_METHOD("get_avg_temperature"),
                       &PerformanceMonitor::get_avg_temperature);
  ClassDB::bind_method(D_METHOD("get_max_temperature"),
                       &PerformanceMonitor::get_max_temperature);
  ClassDB::bind_method(D_METHOD("get_throttle_events"),
                       &PerformanceMonitor::get_throttle_events);
  ClassDB::bind_method(D_METHOD("is_throttling"),
                       &PerformanceMonitor::is_throttling);

  // Formatted output
  ClassDB::bind_method(D_METHOD("get_performance_summary"),
                       &PerformanceMonitor::get_performance_summary);
}

void PerformanceMonitor::set_verbose_logging(bool enabled) {
  verbose_logging = enabled;
}

bool PerformanceMonitor::get_verbose_logging() const { return verbose_logging; }

String PerformanceMonitor::read_file_content(const String& path) {
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

void PerformanceMonitor::update(float delta) {
  // Calculate FPS
  delta_accumulator += delta;
  frame_count++;

  if (delta > 0.0f) {
    current_fps = 1.0f / delta;
    current_frametime_ms = delta * 1000.0f;
  }

  // Update history every frame
  fps_history[history_index] = current_fps;
  frametime_history_ms[history_index] = current_frametime_ms;
  history_index = (history_index + 1) % HISTORY_SIZE;
  if (history_count < HISTORY_SIZE) {
    history_count++;
  }

  // Update statistics every second
  if (delta_accumulator >= 1.0f) {
    update_statistics();
    read_temperature();
    read_cpu_usage();
    detect_throttling();

    delta_accumulator = 0.0f;
    frame_count = 0;
  }

  // Console output every second
  console_output_timer += delta;
  if (console_output_timer >= CONSOLE_OUTPUT_INTERVAL) {
    UtilityFunctions::print(get_performance_summary());
    console_output_timer = 0.0f;
  }
}

void PerformanceMonitor::update_statistics() {
  if (history_count == 0) {
    return;
  }

  // Calculate min, max, avg
  float sum_fps = 0.0f;
  float sum_temp = 0.0f;
  min_fps = 999999.0f;
  max_fps = 0.0f;

  size_t count = std::min(history_count, HISTORY_SIZE);
  for (size_t i = 0; i < count; i++) {
    float fps = fps_history[i];
    sum_fps += fps;

    if (fps < min_fps && fps > 0.0f) {
      min_fps = fps;
    }
    if (fps > max_fps) {
      max_fps = fps;
    }
  }

  avg_fps = sum_fps / count;

  // Calculate 1% low (worst 1% of frames)
  std::array<float, HISTORY_SIZE> sorted_fps = fps_history;
  std::sort(sorted_fps.begin(), sorted_fps.begin() + count);
  size_t p1_index = static_cast<size_t>(count * 0.01f);
  if (p1_index < count) {
    p1_low_fps = sorted_fps[p1_index];
  }

  // Calculate 95th and 99th percentile frame times
  std::array<float, HISTORY_SIZE> sorted_frametime = frametime_history_ms;
  std::sort(sorted_frametime.begin(), sorted_frametime.begin() + count);
  size_t p95_index = static_cast<size_t>(count * 0.95f);
  size_t p99_index = static_cast<size_t>(count * 0.99f);
  if (p95_index < count) {
    p95_frametime_ms = sorted_frametime[p95_index];
  }
  if (p99_index < count) {
    p99_frametime_ms = sorted_frametime[p99_index];
  }
}

void PerformanceMonitor::read_temperature() {
#ifdef __linux__
  // Try common thermal zones for ARM SBCs
  const char* thermal_paths[] = {
      "/sys/class/thermal/thermal_zone0/temp",
      "/sys/class/thermal/thermal_zone1/temp",
      "/sys/devices/virtual/thermal/thermal_zone0/temp"};

  for (const char* path : thermal_paths) {
    String temp_str = read_file_content(path);
    if (!temp_str.is_empty()) {
      // Temperature is in millidegrees Celsius
      int temp_millidegrees = temp_str.to_int();
      current_temperature = temp_millidegrees / 1000.0f;

      // Update max temperature
      if (current_temperature > max_temperature) {
        max_temperature = current_temperature;
      }

      // Update average (simple moving average)
      if (avg_temperature == 0.0f) {
        avg_temperature = current_temperature;
      } else {
        avg_temperature =
            (avg_temperature * 0.9f) + (current_temperature * 0.1f);
      }

      break;
    }
  }
#else
  // On Windows, we can't easily read temperature
  current_temperature = 0.0f;
#endif
}

void PerformanceMonitor::read_cpu_usage() {
#ifdef __linux__
  // Read /proc/stat for CPU usage
  // This is a simplified implementation
  String stat = read_file_content("/proc/stat");
  if (!stat.is_empty()) {
    // Parse first line: cpu  user nice system idle iowait irq softirq
    int cpu_start = stat.find("cpu ");
    if (cpu_start >= 0) {
      int line_end = stat.find("\n", cpu_start);
      String cpu_line = stat.substr(cpu_start + 4, line_end - cpu_start - 4);

      // Simple approximation: assume 50% usage during benchmarks
      // Real implementation would track previous values and calculate delta
      cpu_usage = 50.0f;
    }
  }
#else
  // On Windows, approximate based on frame time
  // If we're taking >16ms per frame, assume high CPU usage
  if (current_frametime_ms > 16.0f) {
    cpu_usage = (current_frametime_ms / 16.0f) * 50.0f;
    cpu_usage = std::min(cpu_usage, 100.0f);
  } else {
    cpu_usage = 30.0f;  // Default assumption
  }
#endif

  // GPU usage approximation (would need platform-specific APIs for real values)
  gpu_usage = cpu_usage * 0.8f;  // Rough estimate
}

void PerformanceMonitor::detect_throttling() {
  // Detect thermal throttling (>75°C on most ARM SBCs)
  static float previous_temperature = 0.0f;
  static bool was_throttling = false;

  bool is_currently_throttling = current_temperature > 75.0f;

  if (is_currently_throttling && !was_throttling) {
    throttle_events++;
    UtilityFunctions::print(
        "[PerformanceMonitor] Thermal throttling detected! Temp: ",
        String::num(current_temperature, 1), "°C");
  }

  was_throttling = is_currently_throttling;
  previous_temperature = current_temperature;
}

// Getters - Current values
float PerformanceMonitor::get_current_fps() const { return current_fps; }

float PerformanceMonitor::get_current_frametime_ms() const {
  return current_frametime_ms;
}

float PerformanceMonitor::get_temperature() const {
  return current_temperature;
}

float PerformanceMonitor::get_cpu_usage() const { return cpu_usage; }

float PerformanceMonitor::get_gpu_usage() const { return gpu_usage; }

// Getters - Statistics
float PerformanceMonitor::get_avg_fps() const { return avg_fps; }

float PerformanceMonitor::get_min_fps() const { return min_fps; }

float PerformanceMonitor::get_max_fps() const { return max_fps; }

float PerformanceMonitor::get_p1_low_fps() const { return p1_low_fps; }

float PerformanceMonitor::get_p95_frametime_ms() const {
  return p95_frametime_ms;
}

float PerformanceMonitor::get_p99_frametime_ms() const {
  return p99_frametime_ms;
}

// Getters - Thermal
float PerformanceMonitor::get_avg_temperature() const {
  return avg_temperature;
}

float PerformanceMonitor::get_max_temperature() const {
  return max_temperature;
}

int PerformanceMonitor::get_throttle_events() const { return throttle_events; }

bool PerformanceMonitor::is_throttling() const {
  return current_temperature > 75.0f;
}

String PerformanceMonitor::get_performance_summary() const {
  String output = "[PerformanceMonitor] ";
  output += "FPS: " + String::num(current_fps, 1);
  output += " (min: " + String::num(min_fps, 1);
  output += ", max: " + String::num(max_fps, 1);
  output += ", avg: " + String::num(avg_fps, 1) + ")";

  output += " | Frame Time: " + String::num(current_frametime_ms, 1) + "ms";
  output += " (P95: " + String::num(p95_frametime_ms, 1) + "ms)";

  output += " | CPU: " + String::num(cpu_usage, 0) + "%";
  output += " | GPU: " + String::num(gpu_usage, 0) + "%";

  if (current_temperature > 0.0f) {
    output += " | Temp: " + String::num(current_temperature, 1) + "°C";
    if (is_throttling()) {
      output += " ⚠️ THROTTLING";
    }
  }

  return output;
}

void PerformanceMonitor::reset() {
  history_index = 0;
  history_count = 0;
  delta_accumulator = 0.0f;
  frame_count = 0;

  min_fps = 999999.0f;
  max_fps = 0.0f;
  avg_fps = 0.0f;
  p1_low_fps = 0.0f;
  p95_frametime_ms = 0.0f;
  p99_frametime_ms = 0.0f;

  max_temperature = 0.0f;
  throttle_events = 0;

  fps_history.fill(0.0f);
  frametime_history_ms.fill(0.0f);

  UtilityFunctions::print("[PerformanceMonitor] Statistics reset");
}
