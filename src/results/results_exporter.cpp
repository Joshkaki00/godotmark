#include "results_exporter.h"

#include <godot_cpp/classes/file_access.hpp>
#include <godot_cpp/classes/json.hpp>
#include <godot_cpp/classes/time.hpp>
#include <godot_cpp/variant/utility_functions.hpp>

ResultsExporter::ResultsExporter()
    : platform_name(""),
      cpu_model(""),
      ram_mb(0),
      gpu_info(""),
      scene_name(""),
      duration_seconds(0.0f),
      avg_fps(0.0f),
      min_fps(0.0f),
      max_fps(0.0f),
      p1_low_fps(0.0f),
      p95_frametime_ms(0.0f),
      p99_frametime_ms(0.0f),
      avg_temperature(0.0f),
      max_temperature(0.0f),
      throttle_events(0),
      triangle_count(0),
      quality_preset(""),
      draw_calls(0),
      vram_usage_mb(0.0f) {}

ResultsExporter::~ResultsExporter() {}

void ResultsExporter::_bind_methods() {
  // Setters
  ClassDB::bind_method(
      D_METHOD("set_platform_info", "platform", "cpu", "ram"),
      &ResultsExporter::set_platform_info);
  ClassDB::bind_method(D_METHOD("set_gpu_info", "gpu"),
                       &ResultsExporter::set_gpu_info);
  ClassDB::bind_method(D_METHOD("set_scene_info", "scene", "duration"),
                       &ResultsExporter::set_scene_info);
  ClassDB::bind_method(
      D_METHOD("set_performance_data", "avg_fps", "min_fps", "p1_low",
               "p95_frame"),
      &ResultsExporter::set_performance_data);
  ClassDB::bind_method(
      D_METHOD("set_performance_extended", "max_fps", "p99_frame"),
      &ResultsExporter::set_performance_extended);
  ClassDB::bind_method(
      D_METHOD("set_thermal_data", "avg_temp", "max_temp", "throttle"),
      &ResultsExporter::set_thermal_data);
  ClassDB::bind_method(D_METHOD("set_load_data", "triangles", "quality"),
                       &ResultsExporter::set_load_data);
  ClassDB::bind_method(D_METHOD("set_draw_calls", "calls"),
                       &ResultsExporter::set_draw_calls);
  ClassDB::bind_method(D_METHOD("set_vram_usage", "mb"),
                       &ResultsExporter::set_vram_usage);

  // Getters
  ClassDB::bind_method(D_METHOD("get_platform_name"),
                       &ResultsExporter::get_platform_name);
  ClassDB::bind_method(D_METHOD("get_cpu_model"),
                       &ResultsExporter::get_cpu_model);
  ClassDB::bind_method(D_METHOD("get_ram_mb"), &ResultsExporter::get_ram_mb);
  ClassDB::bind_method(D_METHOD("get_avg_fps"), &ResultsExporter::get_avg_fps);
  ClassDB::bind_method(D_METHOD("get_min_fps"), &ResultsExporter::get_min_fps);

  // Export
  ClassDB::bind_method(D_METHOD("to_dictionary"),
                       &ResultsExporter::to_dictionary);
  ClassDB::bind_method(D_METHOD("to_json_string"),
                       &ResultsExporter::to_json_string);
  ClassDB::bind_method(D_METHOD("print_console"),
                       &ResultsExporter::print_console);
  ClassDB::bind_method(D_METHOD("save_json", "filepath"),
                       &ResultsExporter::save_json);
}

void ResultsExporter::set_platform_info(const String& platform,
                                        const String& cpu, int ram) {
  platform_name = platform;
  cpu_model = cpu;
  ram_mb = ram;
}

void ResultsExporter::set_gpu_info(const String& gpu) { gpu_info = gpu; }

void ResultsExporter::set_scene_info(const String& scene, float duration) {
  scene_name = scene;
  duration_seconds = duration;
}

void ResultsExporter::set_performance_data(float avg, float min, float p1_low,
                                           float p95_frame) {
  avg_fps = avg;
  min_fps = min;
  p1_low_fps = p1_low;
  p95_frametime_ms = p95_frame;
}

void ResultsExporter::set_performance_extended(float max, float p99_frame) {
  max_fps = max;
  p99_frametime_ms = p99_frame;
}

void ResultsExporter::set_thermal_data(float avg_temp, float max_temp,
                                       int throttle) {
  avg_temperature = avg_temp;
  max_temperature = max_temp;
  throttle_events = throttle;
}

void ResultsExporter::set_load_data(int triangles, const String& quality) {
  triangle_count = triangles;
  quality_preset = quality;
}

void ResultsExporter::set_draw_calls(int calls) { draw_calls = calls; }

void ResultsExporter::set_vram_usage(float mb) { vram_usage_mb = mb; }

String ResultsExporter::get_platform_name() const { return platform_name; }

String ResultsExporter::get_cpu_model() const { return cpu_model; }

int ResultsExporter::get_ram_mb() const { return ram_mb; }

float ResultsExporter::get_avg_fps() const { return avg_fps; }

float ResultsExporter::get_min_fps() const { return min_fps; }

Dictionary ResultsExporter::to_dictionary() const {
  Dictionary result;

  // Timestamp
  result["timestamp"] =
      String::num_int64(Time::get_singleton()->get_unix_time_from_system());

  // Platform
  Dictionary platform;
  platform["name"] = platform_name;
  platform["cpu"] = cpu_model;
  platform["ram_mb"] = ram_mb;
  if (!gpu_info.is_empty()) {
    platform["gpu"] = gpu_info;
  }
  result["platform"] = platform;

  // Scene
  Dictionary scene;
  scene["name"] = scene_name;
  scene["duration_seconds"] = duration_seconds;
  result["scene"] = scene;

  // Performance
  Dictionary performance;
  performance["avg_fps"] = avg_fps;
  performance["min_fps"] = min_fps;
  performance["max_fps"] = max_fps;
  performance["p1_low_fps"] = p1_low_fps;
  performance["p95_frametime_ms"] = p95_frametime_ms;
  performance["p99_frametime_ms"] = p99_frametime_ms;
  result["performance"] = performance;

  // Thermal
  Dictionary thermal;
  thermal["avg_temperature_c"] = avg_temperature;
  thermal["max_temperature_c"] = max_temperature;
  thermal["throttle_events"] = throttle_events;
  result["thermal"] = thermal;

  // Load
  Dictionary load;
  load["triangle_count"] = triangle_count;
  load["draw_calls"] = draw_calls;
  load["quality_preset"] = quality_preset;
  load["vram_usage_mb"] = vram_usage_mb;
  result["load"] = load;

  return result;
}

String ResultsExporter::to_json_string() const {
  Dictionary dict = to_dictionary();
  return JSON::stringify(dict, "  ");  // Pretty print with 2-space indent
}

void ResultsExporter::print_console() const {
  UtilityFunctions::print("\n========================================");
  UtilityFunctions::print("BENCHMARK RESULTS");
  UtilityFunctions::print("========================================\n");

  UtilityFunctions::print("Scene: ", scene_name, " (", duration_seconds, "s)");
  UtilityFunctions::print("Platform: ", platform_name);
  UtilityFunctions::print("CPU: ", cpu_model);
  UtilityFunctions::print("RAM: ", ram_mb, " MB");
  if (!gpu_info.is_empty()) {
    UtilityFunctions::print("GPU: ", gpu_info);
  }

  UtilityFunctions::print("\nPerformance:");
  UtilityFunctions::print("  Average FPS: ", String::num(avg_fps, 1));
  UtilityFunctions::print("  Minimum FPS: ", String::num(min_fps, 1));
  UtilityFunctions::print("  Maximum FPS: ", String::num(max_fps, 1));
  UtilityFunctions::print("  1% Low FPS: ", String::num(p1_low_fps, 1));
  UtilityFunctions::print("  95th Percentile Frame Time: ",
                          String::num(p95_frametime_ms, 2), " ms");
  UtilityFunctions::print("  99th Percentile Frame Time: ",
                          String::num(p99_frametime_ms, 2), " ms");

  UtilityFunctions::print("\nThermal:");
  UtilityFunctions::print("  Average Temperature: ",
                          String::num(avg_temperature, 1), "°C");
  UtilityFunctions::print("  Maximum Temperature: ",
                          String::num(max_temperature, 1), "°C");
  UtilityFunctions::print("  Throttle Events: ", throttle_events);

  UtilityFunctions::print("\nScene Load:");
  UtilityFunctions::print("  Triangle Count: ", triangle_count);
  UtilityFunctions::print("  Draw Calls: ", draw_calls);
  UtilityFunctions::print("  Quality Preset: ", quality_preset);
  UtilityFunctions::print("  VRAM Usage: ", String::num(vram_usage_mb, 1),
                          " MB");

  UtilityFunctions::print("\n========================================\n");
}

bool ResultsExporter::save_json(const String& filepath) {
  String json_string = to_json_string();

  Ref<FileAccess> file = FileAccess::open(filepath, FileAccess::WRITE);
  if (file.is_null()) {
    UtilityFunctions::push_error("[ResultsExporter] Failed to open file: ",
                                 filepath);
    return false;
  }

  file->store_string(json_string);
  file->close();

  UtilityFunctions::print("[ResultsExporter] Results saved to: ", filepath);
  return true;
}
