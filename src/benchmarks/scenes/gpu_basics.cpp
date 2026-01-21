#include "gpu_basics.h"

#include <cmath>
#include <godot_cpp/classes/surface_tool.hpp>
#include <godot_cpp/variant/color.hpp>
#include <godot_cpp/variant/utility_functions.hpp>
#include <godot_cpp/variant/vector3.hpp>

GPUBasicsScene::GPUBasicsScene()
    : triangles_per_object(100),
      spawn_radius(10.0f),
      camera_angle(0.0f),
      camera_speed(0.5f),
      active_object_count(0),
      pool_initialized(false),
      pool_target_size(0),
      pool_batch_size(50) {  // 50 objects per batch
  // Set progressive stress test parameters
  set_max_load(100000);    // Max 100,000 triangles
  set_ramp_rate(1000.0f);  // 1000 triangles/second
  
  // Calculate target pool size
  pool_target_size = get_max_load() / triangles_per_object;  // 1000 objects
}

GPUBasicsScene::~GPUBasicsScene() {
  cleanup_load();

  // Clear object pool (Godot handles child node cleanup)
  object_pool.clear();
  
  // Explicitly clear template vectors to release Ref<> counted resources
  // This ensures ArrayMesh and StandardMaterial3D reference counts decrement
  mesh_templates.clear();
  material_templates.clear();
  
  UtilityFunctions::print("[GPUBasicsScene] Destructor: All resources released");
}

void GPUBasicsScene::_bind_methods() {
  // Bind start_test override so GDScript calls our version
  ClassDB::bind_method(D_METHOD("start_test", "test_duration"),
                       &GPUBasicsScene::start_test, DEFVAL(60.0f));
  
  // Bind incremental template creation methods
  ClassDB::bind_method(D_METHOD("create_single_mesh_template"),
                       &GPUBasicsScene::create_single_mesh_template);
  ClassDB::bind_method(D_METHOD("create_single_material_template"),
                       &GPUBasicsScene::create_single_material_template);
  ClassDB::bind_method(D_METHOD("get_mesh_template_count"),
                       &GPUBasicsScene::get_mesh_template_count);
  ClassDB::bind_method(D_METHOD("get_material_template_count"),
                       &GPUBasicsScene::get_material_template_count);
  
  // Bind lazy pool allocation methods
  ClassDB::bind_method(D_METHOD("allocate_pool_batch", "batch_size"),
                       &GPUBasicsScene::allocate_pool_batch);
  ClassDB::bind_method(D_METHOD("get_pool_size"),
                       &GPUBasicsScene::get_pool_size);
  ClassDB::bind_method(D_METHOD("get_pool_target_size"),
                       &GPUBasicsScene::get_pool_target_size);
  
  // Bind pool management for shader precompilation
  ClassDB::bind_method(D_METHOD("set_active_objects", "count"),
                       &GPUBasicsScene::set_active_objects);
  
  ClassDB::bind_method(D_METHOD("set_triangles_per_object", "count"),
                       &GPUBasicsScene::set_triangles_per_object);
  ClassDB::bind_method(D_METHOD("get_triangles_per_object"),
                       &GPUBasicsScene::get_triangles_per_object);
  ClassDB::bind_method(D_METHOD("get_total_triangles"),
                       &GPUBasicsScene::get_total_triangles);
  ClassDB::bind_method(D_METHOD("get_object_count"),
                       &GPUBasicsScene::get_object_count);
}

void GPUBasicsScene::_ready() {
  ProgressiveStressTest::_ready();
  UtilityFunctions::print("[GPUBasicsScene] Ready (templates deferred to warmup)");
}

void GPUBasicsScene::_process(double delta) {
  // Call parent class process (handles progressive loading)
  ProgressiveStressTest::_process(delta);

  // Animate camera (simple orbit)
  if (get_is_running()) {
    camera_angle += camera_speed * delta;

    // Log status periodically
    static float log_timer = 0.0f;
    log_timer += delta;
    if (log_timer >= 5.0f) {  // Every 5 seconds
      UtilityFunctions::print(get_status());
      UtilityFunctions::print("  Triangles: ", get_total_triangles(),
                              " | Objects: ", get_object_count());
      log_timer = 0.0f;
    }
  }
}

void GPUBasicsScene::create_single_mesh_template() {
  if (mesh_templates.size() >= 5) {
    UtilityFunctions::print("[GPUBasicsScene] WARNING: Already have 5 mesh templates");
    return;
  }
  
  mesh_templates.push_back(create_procedural_mesh(triangles_per_object));
  UtilityFunctions::print("[GPUBasicsScene] Mesh template created (", 
                          mesh_templates.size(), "/5)");
}

void GPUBasicsScene::create_single_material_template() {
  if (material_templates.size() >= 5) {
    UtilityFunctions::print("[GPUBasicsScene] WARNING: Already have 5 material templates");
    return;
  }
  
  material_templates.push_back(create_test_material());
  UtilityFunctions::print("[GPUBasicsScene] Material template created (",
                          material_templates.size(), "/5)");
}

int GPUBasicsScene::get_mesh_template_count() const {
  return mesh_templates.size();
}

int GPUBasicsScene::get_material_template_count() const {
  return material_templates.size();
}

void GPUBasicsScene::start_test(float test_duration) {
  UtilityFunctions::print("[GPUBasicsScene] start_test() called");
  
  // Check if pool is complete
  if (object_pool.size() < pool_target_size) {
    UtilityFunctions::print("[GPUBasicsScene] WARNING: Pool not fully initialized! ",
                            object_pool.size(), "/", pool_target_size);
    // Complete initialization synchronously as fallback
    int remaining = pool_target_size - object_pool.size();
    allocate_pool_batch(remaining);
  }
  
  if (!pool_initialized) {
    pool_initialized = true;
    UtilityFunctions::print("[GPUBasicsScene] Pool ready - ", 
                            object_pool.size(), " objects");
  }
  
  // Call parent start_test
  ProgressiveStressTest::start_test(test_duration);
}

void GPUBasicsScene::apply_load(int load) {
  // Calculate how many objects we need for this triangle count
  int target_objects = load / triangles_per_object;
  
  // Debug logging (only log changes)
  static int last_target = -1;
  if (target_objects != last_target) {
    UtilityFunctions::print("[GPUBasicsScene] apply_load: target_objects = ",
                            target_objects, " (load = ", load, ")");
    last_target = target_objects;
  }
  
  // Use object pooling - just show/hide objects (no allocation/deallocation)
  set_active_objects(target_objects);
}

void GPUBasicsScene::cleanup_load() {
  // Hide all objects (don't delete them - they're in the pool)
  set_active_objects(0);
}

void GPUBasicsScene::allocate_pool_batch(int batch_size) {
  int current_size = object_pool.size();
  int objects_to_create = std::min(batch_size, pool_target_size - current_size);
  
  if (objects_to_create <= 0) {
    UtilityFunctions::print("[GPUBasicsScene] Pool already at target size: ", current_size);
    return;
  }
  
  for (int i = 0; i < objects_to_create; i++) {
    MeshInstance3D* instance = memnew(MeshInstance3D);
    int pool_index = current_size + i;
    
    // Assign mesh from templates (cycle through)
    instance->set_mesh(mesh_templates[pool_index % mesh_templates.size()]);
    
    // Assign material from templates
    instance->set_surface_override_material(
        0, material_templates[pool_index % material_templates.size()]);
    
    // Random position in sphere
    float theta = UtilityFunctions::randf() * Math_PI * 2.0f;
    float phi = UtilityFunctions::randf() * Math_PI;
    float r = UtilityFunctions::randf() * spawn_radius;
    Vector3 pos(r * sin(phi) * cos(theta), r * sin(phi) * sin(theta),
                r * cos(phi));
    instance->set_position(pos);
    
    // Random rotation
    Vector3 rot(UtilityFunctions::randf() * Math_PI * 2.0f,
                UtilityFunctions::randf() * Math_PI * 2.0f,
                UtilityFunctions::randf() * Math_PI * 2.0f);
    instance->set_rotation(rot);
    
    // Add to scene (but hide initially)
    add_child(instance);
    instance->set_visible(false);
    
    object_pool.push_back(instance);
  }
  
  UtilityFunctions::print("[GPUBasicsScene] Pool batch allocated: ", objects_to_create,
                          " objects (", object_pool.size(), "/", pool_target_size, ")");
}

void GPUBasicsScene::set_active_objects(int count) {
  // Clamp to pool size
  count = std::min(count, static_cast<int>(object_pool.size()));

  // Debug logging
  static int last_count = -1;
  if (count != last_count) {
    UtilityFunctions::print("[GPUBasicsScene] set_active_objects: ",
                            active_object_count, " -> ", count);
    last_count = count;
  }

  if (count > active_object_count) {
    // Show more objects
    for (int i = active_object_count; i < count; i++) {
      object_pool[i]->set_visible(true);
    }
  } else if (count < active_object_count) {
    // Hide some objects
    for (int i = count; i < active_object_count; i++) {
      object_pool[i]->set_visible(false);
    }
  }

  active_object_count = count;
}

Ref<ArrayMesh> GPUBasicsScene::create_procedural_mesh(int triangle_count) {
  Ref<SurfaceTool> st = memnew(SurfaceTool);
  st->begin(Mesh::PRIMITIVE_TRIANGLES);

  // Create a simple icosphere-like mesh
  // For simplicity, create random triangles
  for (int i = 0; i < triangle_count; i++) {
    // Random triangle vertices
    for (int v = 0; v < 3; v++) {
      Vector3 vertex((UtilityFunctions::randf() - 0.5f) * 2.0f,
                     (UtilityFunctions::randf() - 0.5f) * 2.0f,
                     (UtilityFunctions::randf() - 0.5f) * 2.0f);

      Vector3 normal = vertex.normalized();
      Color color(UtilityFunctions::randf(), UtilityFunctions::randf(),
                  UtilityFunctions::randf());

      st->set_normal(normal);
      st->set_color(color);
      st->add_vertex(vertex);
    }
  }

  return st->commit();
}

Ref<StandardMaterial3D> GPUBasicsScene::create_test_material() {
  Ref<StandardMaterial3D> material = memnew(StandardMaterial3D);

  // Random base color
  Color base_color(0.5f + UtilityFunctions::randf() * 0.5f,
                   0.5f + UtilityFunctions::randf() * 0.5f,
                   0.5f + UtilityFunctions::randf() * 0.5f);

  material->set_albedo(base_color);
  material->set_metallic(0.5f);
  material->set_roughness(0.5f);

  return material;
}

void GPUBasicsScene::set_triangles_per_object(int count) {
  triangles_per_object = std::max(count, 1);
}

int GPUBasicsScene::get_triangles_per_object() const {
  return triangles_per_object;
}

int GPUBasicsScene::get_total_triangles() const {
  return active_object_count * triangles_per_object;
}

int GPUBasicsScene::get_object_count() const { 
  return active_object_count; 
}

int GPUBasicsScene::get_pool_size() const {
  return object_pool.size();
}

int GPUBasicsScene::get_pool_target_size() const {
  return pool_target_size;
}
