#include "benchmark_orchestrator.h"

#include <godot_cpp/classes/time.hpp>
#include <godot_cpp/variant/utility_functions.hpp>

BenchmarkOrchestrator::BenchmarkOrchestrator()
    : is_initialized(false), is_running(false), current_scene_name("") {}

BenchmarkOrchestrator::~BenchmarkOrchestrator() {}

void BenchmarkOrchestrator::_bind_methods() {
  ClassDB::bind_method(D_METHOD("run_benchmark", "scene_name"),
                       &BenchmarkOrchestrator::run_benchmark,
                       DEFVAL("gpu_basics"));
  ClassDB::bind_method(D_METHOD("stop_benchmark"),
                       &BenchmarkOrchestrator::stop_benchmark);

  ClassDB::bind_method(D_METHOD("get_platform_detector"),
                       &BenchmarkOrchestrator::get_platform_detector);
  ClassDB::bind_method(D_METHOD("get_performance_monitor"),
                       &BenchmarkOrchestrator::get_performance_monitor);
  ClassDB::bind_method(D_METHOD("get_quality_manager"),
                       &BenchmarkOrchestrator::get_quality_manager);
  ClassDB::bind_method(D_METHOD("get_results_exporter"),
                       &BenchmarkOrchestrator::get_results_exporter);

  ClassDB::bind_method(D_METHOD("get_is_initialized"),
                       &BenchmarkOrchestrator::get_is_initialized);
  ClassDB::bind_method(D_METHOD("get_is_running"),
                       &BenchmarkOrchestrator::get_is_running);
  ClassDB::bind_method(D_METHOD("get_current_scene"),
                       &BenchmarkOrchestrator::get_current_scene);
}

void BenchmarkOrchestrator::_ready() {
  UtilityFunctions::print("\n");
  UtilityFunctions::print("========================================");
  UtilityFunctions::print("GodotMark Benchmark Suite");
  UtilityFunctions::print("ARM Single-Board Computer Edition");
  UtilityFunctions::print("========================================");
  UtilityFunctions::print("\n");

  initialize_systems();
}

void BenchmarkOrchestrator::_process(double delta) {
  if (!is_running || !is_initialized) {
    return;
  }

  // Update performance monitor
  if (performance_monitor.is_valid()) {
    performance_monitor->update(delta);
  }

  // Update adaptive quality based on performance
  if (quality_manager.is_valid() && performance_monitor.is_valid()) {
    float current_fps = performance_monitor->get_current_fps();
    float current_temp = performance_monitor->get_temperature();
    quality_manager->update(current_fps, current_temp);
  }
}

void BenchmarkOrchestrator::initialize_systems() {
  UtilityFunctions::print("[BenchmarkOrchestrator] Initializing systems...");

  // Create platform detector
  platform_detector.instantiate();
  platform_detector->initialize();

  // Create performance monitor
  performance_monitor.instantiate();

  // Create adaptive quality manager
  quality_manager.instantiate();
  quality_manager->initialize(AdaptiveQualityManager::MEDIUM);

  // Create results exporter
  results_exporter.instantiate();

  is_initialized = true;
  UtilityFunctions::print("[BenchmarkOrchestrator] Initialization complete!");
  UtilityFunctions::print("\n");
}

void BenchmarkOrchestrator::run_benchmark(const String& scene_name) {
  if (!is_initialized) {
    UtilityFunctions::push_error("[BenchmarkOrchestrator] Not initialized!");
    return;
  }

  if (is_running) {
    UtilityFunctions::push_warning(
        "[BenchmarkOrchestrator] Benchmark already running!");
    return;
  }

  current_scene_name = scene_name;
  is_running = true;

  UtilityFunctions::print("[BenchmarkOrchestrator] Starting benchmark: ",
                          scene_name);
  UtilityFunctions::print("\n");

  run_benchmark_internal(scene_name);
}

void BenchmarkOrchestrator::run_benchmark_internal(const String& scene_name) {
  // In a full implementation, this would:
  // 1. Load the specified scene
  // 2. Wait for completion
  // 3. Collect results
  // 4. Export results

  // For the minimal prototype, the scene handles its own execution
  // We just provide the systems it needs to use

  UtilityFunctions::print(
      "[BenchmarkOrchestrator] Benchmark scene is now running.");
  UtilityFunctions::print(
      "[BenchmarkOrchestrator] Performance monitoring active.");
  UtilityFunctions::print(
      "[BenchmarkOrchestrator] Adaptive quality management active.");
  UtilityFunctions::print("\n");
}

void BenchmarkOrchestrator::stop_benchmark() {
  if (!is_running) {
    return;
  }

  is_running = false;

  UtilityFunctions::print("\n");
  UtilityFunctions::print("[BenchmarkOrchestrator] Stopping benchmark...");

  finalize_results();
}

void BenchmarkOrchestrator::finalize_results() {
  if (!results_exporter.is_valid()) {
    return;
  }

  // Gather results from all systems
  if (platform_detector.is_valid()) {
    results_exporter->set_platform_info(platform_detector->get_platform_name(),
                                        platform_detector->get_cpu_model(),
                                        platform_detector->get_ram_mb());
  }

  if (performance_monitor.is_valid()) {
    results_exporter->set_performance_data(
        performance_monitor->get_avg_fps(), performance_monitor->get_min_fps(),
        performance_monitor->get_p1_low_fps(),
        performance_monitor->get_p95_frametime_ms());

    results_exporter->set_thermal_data(
        performance_monitor->get_avg_temperature(),
        performance_monitor->get_max_temperature(),
        performance_monitor->get_throttle_events());
  }

  if (quality_manager.is_valid()) {
    results_exporter->set_scene_info(current_scene_name, 60.0f);
    results_exporter->set_load_data(0, quality_manager->get_quality_name());
  }

  // Print results to console
  results_exporter->print_console();

  // Save to JSON
  String results_dir = "user://results/";
  String timestamp =
      String::num_int64(Time::get_singleton()->get_unix_time_from_system());
  String filename =
      results_dir + current_scene_name + "_" + timestamp + ".json";

  results_exporter->save_json(filename);

  UtilityFunctions::print("[BenchmarkOrchestrator] Benchmark complete!");
}

Ref<PlatformDetector> BenchmarkOrchestrator::get_platform_detector() const {
  return platform_detector;
}

Ref<PerformanceMonitor> BenchmarkOrchestrator::get_performance_monitor() const {
  return performance_monitor;
}

Ref<AdaptiveQualityManager> BenchmarkOrchestrator::get_quality_manager() const {
  return quality_manager;
}

Ref<ResultsExporter> BenchmarkOrchestrator::get_results_exporter() const {
  return results_exporter;
}

bool BenchmarkOrchestrator::get_is_initialized() const {
  return is_initialized;
}

bool BenchmarkOrchestrator::get_is_running() const { return is_running; }

String BenchmarkOrchestrator::get_current_scene() const {
  return current_scene_name;
}
