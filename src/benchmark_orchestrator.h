#ifndef GODOTMARK_BENCHMARK_ORCHESTRATOR_H
#define GODOTMARK_BENCHMARK_ORCHESTRATOR_H

#include <godot_cpp/classes/node.hpp>
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/variant/string.hpp>
#include "platform/platform_detector.h"
#include "performance/performance_monitor.h"
#include "benchmarks/adaptive_quality_manager.h"
#include "results/results_exporter.h"

using namespace godot;

class BenchmarkOrchestrator : public Node {
    GDCLASS(BenchmarkOrchestrator, Node)

private:
    // Core systems
    Ref<PlatformDetector> platform_detector;
    Ref<PerformanceMonitor> performance_monitor;
    Ref<AdaptiveQualityManager> quality_manager;
    Ref<ResultsExporter> results_exporter;
    
    // State
    bool is_initialized;
    bool is_running;
    String current_scene_name;
    
    // Workflow steps
    void initialize_systems();
    void run_benchmark_internal(const String& scene_name);
    void finalize_results();

protected:
    static void _bind_methods();

public:
    BenchmarkOrchestrator();
    ~BenchmarkOrchestrator();
    
    virtual void _ready() override;
    virtual void _process(double delta) override;
    
    // Main workflow
    void run_benchmark(const String& scene_name = "gpu_basics");
    void stop_benchmark();
    
    // System access
    Ref<PlatformDetector> get_platform_detector() const;
    Ref<PerformanceMonitor> get_performance_monitor() const;
    Ref<AdaptiveQualityManager> get_quality_manager() const;
    Ref<ResultsExporter> get_results_exporter() const;
    
    // Status
    bool get_is_initialized() const;
    bool get_is_running() const;
    String get_current_scene() const;
};

#endif // GODOTMARK_BENCHMARK_ORCHESTRATOR_H

