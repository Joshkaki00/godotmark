#ifndef GODOTMARK_GPU_BASICS_H
#define GODOTMARK_GPU_BASICS_H

#include <godot_cpp/classes/array_mesh.hpp>
#include <godot_cpp/classes/mesh_instance3d.hpp>
#include <godot_cpp/classes/standard_material3d.hpp>
#include <godot_cpp/variant/packed_vector3_array.hpp>
#include <vector>

#include "../progressive_stress_test.h"

using namespace godot;

class GPUBasicsScene : public ProgressiveStressTest {
  GDCLASS(GPUBasicsScene, ProgressiveStressTest)

 private:
  // Object pool (all objects pre-created, show/hide as needed)
  std::vector<MeshInstance3D*> object_pool;
  int active_object_count;
  bool pool_initialized;
  
  int pool_target_size;  // Target pool size for lazy allocation
  int pool_batch_size;   // Objects to create per batch

  // Shared resources (created once, reused across all objects)
  std::vector<Ref<ArrayMesh>> mesh_templates;
  std::vector<Ref<StandardMaterial3D>> material_templates;

  // Configuration
  int triangles_per_object;
  float spawn_radius;

  // Camera animation
  float camera_angle;
  float camera_speed;

  // Mesh generation
  Ref<ArrayMesh> create_procedural_mesh(int triangle_count);
  Ref<StandardMaterial3D> create_test_material();

  // Pool management
  void set_active_objects(int count);

 protected:
  static void _bind_methods();

 public:
  GPUBasicsScene();
  ~GPUBasicsScene();

  virtual void _ready() override;
  virtual void _process(double delta) override;

  // Override from ProgressiveStressTest
  void start_test(float test_duration = 60.0f);
  virtual void apply_load(int load) override;
  virtual void cleanup_load() override;

  // Incremental template creation (one per frame during warmup)
  void create_single_mesh_template();
  void create_single_material_template();
  int get_mesh_template_count() const;
  int get_material_template_count() const;

  // Lazy pool allocation (called from GDScript warmup)
  void allocate_pool_batch(int batch_size);
  int get_pool_size() const;
  int get_pool_target_size() const;

  // Configuration
  void set_triangles_per_object(int count);
  int get_triangles_per_object() const;

  // Status
  int get_total_triangles() const;
  int get_object_count() const;
};

#endif  // GODOTMARK_GPU_BASICS_H
