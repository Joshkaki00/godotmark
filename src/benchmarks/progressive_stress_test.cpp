#include "progressive_stress_test.h"

#include <algorithm>
#include <godot_cpp/variant/utility_functions.hpp>

bool ProgressiveStressTest::verbose_logging = false;

ProgressiveStressTest::ProgressiveStressTest()
    : current_load(0),
      max_load(10000),
      ramp_rate(100.0f),
      elapsed_time(0.0f),
      duration(60.0f),
      is_running(false),
      is_complete(false),
      quick_test_mode(false),
      quick_test_duration(10.0f),
      peak_load_achieved(0),
      peak_load_fps(0.0f) {}

ProgressiveStressTest::~ProgressiveStressTest() {}

void ProgressiveStressTest::_bind_methods() {
  ClassDB::bind_method(D_METHOD("start_test", "test_duration"),
                       &ProgressiveStressTest::start_test, DEFVAL(60.0f));
  ClassDB::bind_method(D_METHOD("stop_test"),
                       &ProgressiveStressTest::stop_test);
  ClassDB::bind_method(D_METHOD("reset_test"),
                       &ProgressiveStressTest::reset_test);

  ClassDB::bind_method(D_METHOD("set_max_load", "load"),
                       &ProgressiveStressTest::set_max_load);
  ClassDB::bind_method(D_METHOD("get_max_load"),
                       &ProgressiveStressTest::get_max_load);
  ClassDB::bind_method(D_METHOD("set_ramp_rate", "rate"),
                       &ProgressiveStressTest::set_ramp_rate);
  ClassDB::bind_method(D_METHOD("get_ramp_rate"),
                       &ProgressiveStressTest::get_ramp_rate);

  ClassDB::bind_method(D_METHOD("set_quick_test_mode", "enabled", "duration"),
                       &ProgressiveStressTest::set_quick_test_mode,
                       DEFVAL(10.0f));
  ClassDB::bind_method(D_METHOD("get_quick_test_mode"),
                       &ProgressiveStressTest::get_quick_test_mode);
  ClassDB::bind_method(D_METHOD("set_verbose_logging", "enabled"),
                       &ProgressiveStressTest::set_verbose_logging);
  ClassDB::bind_method(D_METHOD("get_verbose_logging"),
                       &ProgressiveStressTest::get_verbose_logging);

  ClassDB::bind_method(D_METHOD("get_is_running"),
                       &ProgressiveStressTest::get_is_running);
  ClassDB::bind_method(D_METHOD("get_is_complete"),
                       &ProgressiveStressTest::get_is_complete);
  ClassDB::bind_method(D_METHOD("get_elapsed_time"),
                       &ProgressiveStressTest::get_elapsed_time);
  ClassDB::bind_method(D_METHOD("get_progress"),
                       &ProgressiveStressTest::get_progress);

  ClassDB::bind_method(D_METHOD("get_current_load"),
                       &ProgressiveStressTest::get_current_load);
  ClassDB::bind_method(D_METHOD("get_load_percentage"),
                       &ProgressiveStressTest::get_load_percentage);
  ClassDB::bind_method(D_METHOD("get_peak_load"),
                       &ProgressiveStressTest::get_peak_load);
  ClassDB::bind_method(D_METHOD("get_status"),
                       &ProgressiveStressTest::get_status);
}

void ProgressiveStressTest::_ready() {
  UtilityFunctions::print("[ProgressiveStressTest] Ready");
}

void ProgressiveStressTest::_process(double delta) {
  if (!is_running || is_complete) {
    return;
  }

  elapsed_time += delta;

  // Check if test duration is complete
  if (elapsed_time >= duration) {
    stop_test();
    return;
  }

  // Get current FPS (would come from PerformanceMonitor in real usage)
  // For now, use Engine.get_frames_per_second() equivalent
  float current_fps = 1.0f / std::max(0.001f, static_cast<float>(delta));

  // Update load based on performance
  update_load(current_fps, delta);

  // Apply the load (subclass implements this)
  apply_load(current_load);
}

void ProgressiveStressTest::start_test(float test_duration) {
  // Use quick test duration if enabled
  duration = quick_test_mode ? quick_test_duration : test_duration;
  elapsed_time = 0.0f;
  current_load = 1000;  // Start with 1000 units
  peak_load_achieved = current_load;
  is_running = true;
  is_complete = false;

  if (quick_test_mode) {
    UtilityFunctions::print("[ProgressiveStressTest] Starting QUICK TEST (",
                            duration, " seconds)");
  } else {
    UtilityFunctions::print("[ProgressiveStressTest] Starting test (", duration,
                            " seconds)");
  }
}

void ProgressiveStressTest::stop_test() {
  is_running = false;
  is_complete = true;

  cleanup_load();

  UtilityFunctions::print("[ProgressiveStressTest] Test complete!");
  UtilityFunctions::print("  Duration: ", String::num(elapsed_time, 1),
                          " seconds");
  UtilityFunctions::print("  Peak Load: ", peak_load_achieved, " (",
                          String::num(get_load_percentage(), 1), "%)");
}

void ProgressiveStressTest::reset_test() {
  is_running = false;
  is_complete = false;
  elapsed_time = 0.0f;
  current_load = 0;
  peak_load_achieved = 0;
  peak_load_fps = 0.0f;

  cleanup_load();

  UtilityFunctions::print("[ProgressiveStressTest] Reset");
}

void ProgressiveStressTest::update_load(float current_fps, float delta) {
  int old_load = current_load;

  // Ramp up if performance is good
  if (current_fps > RAMP_UP_FPS_THRESHOLD && current_load < max_load) {
    current_load += static_cast<int>(ramp_rate * delta);
    current_load = std::min(current_load, max_load);
  }
  // Ramp down if performance is poor
  else if (current_fps < RAMP_DOWN_FPS_THRESHOLD && current_load > 0) {
    current_load -= static_cast<int>(ramp_rate * delta * 2.0f);
    current_load = std::max(current_load, 0);
  }

  // Track peak load
  if (current_load > peak_load_achieved) {
    peak_load_achieved = current_load;
    peak_load_fps = current_fps;
  }

  // Log significant changes
  if (abs(current_load - old_load) > ramp_rate * 5.0f) {
    UtilityFunctions::print("[ProgressiveStressTest] Load: ", current_load,
                            " | FPS: ", String::num(current_fps, 1));
  }
}

void ProgressiveStressTest::set_max_load(int load) {
  max_load = std::max(load, 1);
}

int ProgressiveStressTest::get_max_load() const { return max_load; }

void ProgressiveStressTest::set_ramp_rate(float rate) {
  ramp_rate = std::max(rate, 1.0f);
}

float ProgressiveStressTest::get_ramp_rate() const { return ramp_rate; }

bool ProgressiveStressTest::get_is_running() const { return is_running; }

bool ProgressiveStressTest::get_is_complete() const { return is_complete; }

float ProgressiveStressTest::get_elapsed_time() const { return elapsed_time; }

float ProgressiveStressTest::get_progress() const {
  if (duration <= 0.0f) return 0.0f;
  return std::min(elapsed_time / duration, 1.0f);
}

int ProgressiveStressTest::get_current_load() const { return current_load; }

float ProgressiveStressTest::get_load_percentage() const {
  if (max_load <= 0) return 0.0f;
  return (static_cast<float>(current_load) / max_load) * 100.0f;
}

int ProgressiveStressTest::get_peak_load() const { return peak_load_achieved; }

String ProgressiveStressTest::get_status() const {
  String status = "[ProgressiveStressTest] ";

  if (!is_running && !is_complete) {
    status += "Not started";
  } else if (is_complete) {
    status += "Complete - Peak: " + String::num_int64(peak_load_achieved);
  } else {
    status += "Load: " + String::num_int64(current_load) + "/" +
              String::num_int64(max_load);
    status += " (" + String::num(get_load_percentage(), 1) + "%)";
    status += " | Time: " + String::num(elapsed_time, 1) + "/" +
              String::num(duration, 1) + "s";
  }

  return status;
}

void ProgressiveStressTest::set_quick_test_mode(bool enabled, float duration) {
  quick_test_mode = enabled;
  quick_test_duration = duration;
  if (verbose_logging) {
    UtilityFunctions::print(
        "[Verbose] Quick test mode: ", enabled ? "enabled" : "disabled", " (",
        duration, "s)");
  }
}

bool ProgressiveStressTest::get_quick_test_mode() const {
  return quick_test_mode;
}

void ProgressiveStressTest::set_verbose_logging(bool enabled) {
  verbose_logging = enabled;
}

bool ProgressiveStressTest::get_verbose_logging() const {
  return verbose_logging;
}
