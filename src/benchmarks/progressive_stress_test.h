#ifndef GODOTMARK_PROGRESSIVE_STRESS_TEST_H
#define GODOTMARK_PROGRESSIVE_STRESS_TEST_H

#include <godot_cpp/classes/node3d.hpp>
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/variant/string.hpp>

using namespace godot;

class ProgressiveStressTest : public Node3D {
  GDCLASS(ProgressiveStressTest, Node3D)

 protected:
  // Current load level
  int current_load;
  int max_load;
  float ramp_rate;  // Units per second

  // Timing
  float elapsed_time;
  float duration;  // Total test duration
  bool is_running;
  bool is_complete;

  // Quick test mode
  bool quick_test_mode;
  float quick_test_duration;

  // Peak tracking
  int peak_load_achieved;
  float peak_load_fps;

  // Performance thresholds for ramping
  static constexpr float RAMP_UP_FPS_THRESHOLD = 25.0f;
  static constexpr float RAMP_DOWN_FPS_THRESHOLD = 15.0f;

  // Debug flag
  static bool verbose_logging;

  static void _bind_methods();

 public:
  ProgressiveStressTest();
  ~ProgressiveStressTest();

  // Lifecycle
  virtual void _ready() override;
  virtual void _process(double delta) override;

  // Control
  void start_test(float test_duration = 60.0f);
  void stop_test();
  void reset_test();

  // Configuration
  void set_max_load(int load);
  int get_max_load() const;

  void set_ramp_rate(float rate);
  float get_ramp_rate() const;

  // Quick test mode
  void set_quick_test_mode(bool enabled, float duration = 10.0f);
  bool get_quick_test_mode() const;

  // Debug control
  void set_verbose_logging(bool enabled);
  bool get_verbose_logging() const;

  // Status
  bool get_is_running() const;
  bool get_is_complete() const;
  float get_elapsed_time() const;
  float get_progress() const;  // 0.0 to 1.0

  // Current state
  int get_current_load() const;
  float get_load_percentage() const;
  int get_peak_load() const;

  // Formatted status
  String get_status() const;

  // Virtual methods for subclasses to implement
  virtual void apply_load(int load) {}
  virtual void cleanup_load() {}

 protected:
  // Update load based on FPS
  void update_load(float current_fps, float delta);
};

#endif  // GODOTMARK_PROGRESSIVE_STRESS_TEST_H
