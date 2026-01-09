#include "register_types.h"

#include <gdextension_interface.h>
#include <godot_cpp/core/defs.hpp>
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/godot.hpp>

// Forward declarations for classes (will be implemented in subsequent phases)
#include "platform/platform_detector.h"
#include "performance/performance_monitor.h"
#include "benchmarks/adaptive_quality_manager.h"
#include "benchmarks/progressive_stress_test.h"
#include "benchmarks/scenes/gpu_basics.h"
#include "results/results_exporter.h"
#include "benchmark_orchestrator.h"

using namespace godot;

void initialize_godotmark_module(ModuleInitializationLevel p_level) {
    if (p_level != MODULE_INITIALIZATION_LEVEL_SCENE) {
        return;
    }

    // Register classes here as they are implemented
    // Phase 2: Platform Detection
    ClassDB::register_class<PlatformDetector>();
    
    // Phase 2: Performance Monitoring
    ClassDB::register_class<PerformanceMonitor>();
    
    // Phase 2: Adaptive Quality
    ClassDB::register_class<AdaptiveQualityManager>();
    
    // Phase 3: Progressive Stress Testing
    ClassDB::register_class<ProgressiveStressTest>();
    
    // Phase 3: GPU Basics Scene
    ClassDB::register_class<GPUBasicsScene>();
    
    // Phase 4: Results Export
    ClassDB::register_class<ResultsExporter>();
    
    // Phase 4: Orchestrator
    ClassDB::register_class<BenchmarkOrchestrator>();
    
    print_line("[GodotMark] Extension initialized");
}

void uninitialize_godotmark_module(ModuleInitializationLevel p_level) {
    if (p_level != MODULE_INITIALIZATION_LEVEL_SCENE) {
        return;
    }
    
    print_line("[GodotMark] Extension uninitialized");
}

extern "C" {
    // Initialization
    GDExtensionBool GDE_EXPORT godotmark_library_init(GDExtensionInterfaceGetProcAddress p_get_proc_address, const GDExtensionClassLibraryPtr p_library, GDExtensionInitialization *r_initialization) {
        godot::GDExtensionBinding::InitObject init_obj(p_get_proc_address, p_library, r_initialization);

        init_obj.register_initializer(initialize_godotmark_module);
        init_obj.register_terminator(uninitialize_godotmark_module);
        init_obj.set_minimum_library_initialization_level(MODULE_INITIALIZATION_LEVEL_SCENE);

        return init_obj.init();
    }
}

