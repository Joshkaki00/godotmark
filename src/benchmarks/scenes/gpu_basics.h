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
  // Scene objects
  std::vector<MeshInstance3D*> mesh_instances;

  // Configuration
  int triangles_per_object;
  float spawn_radius;

  // Camera animation
  float camera_angle;
  float camera_speed;

  // Mesh generation
  Ref<ArrayMesh> create_procedural_mesh(int triangle_count);
  Ref<StandardMaterial3D> create_test_material();

  // Object management
  void spawn_objects(int count);
  void despawn_all_objects();

 protected:
  static void _bind_methods();

 public:
  GPUBasicsScene();
  ~GPUBasicsScene();

  virtual void _ready() override;
  virtual void _process(double delta) override;

  // Override from ProgressiveStressTest
  virtual void apply_load(int load) override;
  virtual void cleanup_load() override;

  // Configuration
  void set_triangles_per_object(int count);
  int get_triangles_per_object() const;

  // Status
  int get_total_triangles() const;
  int get_object_count() const;
};

#endif  // GODOTMARK_GPU_BASICS_H
