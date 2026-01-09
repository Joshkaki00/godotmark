#include "gpu_basics.h"
#include <godot_cpp/variant/utility_functions.hpp>
#include <godot_cpp/classes/surface_tool.hpp>
#include <godot_cpp/variant/vector3.hpp>
#include <godot_cpp/variant/color.hpp>
#include <cmath>

GPUBasicsScene::GPUBasicsScene() :
    triangles_per_object(100),
    spawn_radius(10.0f),
    camera_angle(0.0f),
    camera_speed(0.5f) {
    
    // Set progressive stress test parameters
    set_max_load(100000);  // Max 100,000 triangles
    set_ramp_rate(1000.0f); // 1000 triangles/second
}

GPUBasicsScene::~GPUBasicsScene() {
    cleanup_load();
}

void GPUBasicsScene::_bind_methods() {
    ClassDB::bind_method(D_METHOD("set_triangles_per_object", "count"), &GPUBasicsScene::set_triangles_per_object);
    ClassDB::bind_method(D_METHOD("get_triangles_per_object"), &GPUBasicsScene::get_triangles_per_object);
    ClassDB::bind_method(D_METHOD("get_total_triangles"), &GPUBasicsScene::get_total_triangles);
    ClassDB::bind_method(D_METHOD("get_object_count"), &GPUBasicsScene::get_object_count);
}

void GPUBasicsScene::_ready() {
    ProgressiveStressTest::_ready();
    
    UtilityFunctions::print("[GPUBasicsScene] Ready - Max Load: ", get_max_load(), " triangles");
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

void GPUBasicsScene::apply_load(int load) {
    // Calculate how many objects we need for this triangle count
    int target_objects = load / triangles_per_object;
    int current_objects = mesh_instances.size();
    
    if (target_objects > current_objects) {
        // Spawn more objects
        int to_spawn = target_objects - current_objects;
        spawn_objects(to_spawn);
    } else if (target_objects < current_objects) {
        // Despawn some objects
        int to_despawn = current_objects - target_objects;
        for (int i = 0; i < to_despawn && !mesh_instances.empty(); i++) {
            MeshInstance3D* instance = mesh_instances.back();
            mesh_instances.pop_back();
            remove_child(instance);
            memdelete(instance);
        }
    }
}

void GPUBasicsScene::cleanup_load() {
    despawn_all_objects();
}

void GPUBasicsScene::spawn_objects(int count) {
    for (int i = 0; i < count; i++) {
        MeshInstance3D* instance = memnew(MeshInstance3D);
        
        // Create procedural mesh
        instance->set_mesh(create_procedural_mesh(triangles_per_object));
        
        // Set material
        instance->set_surface_override_material(0, create_test_material());
        
        // Random position in a sphere
        float theta = UtilityFunctions::randf() * Math_PI * 2.0f;
        float phi = UtilityFunctions::randf() * Math_PI;
        float r = UtilityFunctions::randf() * spawn_radius;
        
        Vector3 pos(
            r * sin(phi) * cos(theta),
            r * sin(phi) * sin(theta),
            r * cos(phi)
        );
        
        instance->set_position(pos);
        
        // Random rotation
        Vector3 rot(
            UtilityFunctions::randf() * Math_PI * 2.0f,
            UtilityFunctions::randf() * Math_PI * 2.0f,
            UtilityFunctions::randf() * Math_PI * 2.0f
        );
        instance->set_rotation(rot);
        
        add_child(instance);
        mesh_instances.push_back(instance);
    }
}

void GPUBasicsScene::despawn_all_objects() {
    for (MeshInstance3D* instance : mesh_instances) {
        remove_child(instance);
        memdelete(instance);
    }
    mesh_instances.clear();
}

Ref<ArrayMesh> GPUBasicsScene::create_procedural_mesh(int triangle_count) {
    Ref<SurfaceTool> st = memnew(SurfaceTool);
    st->begin(Mesh::PRIMITIVE_TRIANGLES);
    
    // Create a simple icosphere-like mesh
    // For simplicity, create random triangles
    for (int i = 0; i < triangle_count; i++) {
        // Random triangle vertices
        for (int v = 0; v < 3; v++) {
            Vector3 vertex(
                (UtilityFunctions::randf() - 0.5f) * 2.0f,
                (UtilityFunctions::randf() - 0.5f) * 2.0f,
                (UtilityFunctions::randf() - 0.5f) * 2.0f
            );
            
            Vector3 normal = vertex.normalized();
            Color color(UtilityFunctions::randf(), UtilityFunctions::randf(), UtilityFunctions::randf());
            
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
    Color base_color(
        0.5f + UtilityFunctions::randf() * 0.5f,
        0.5f + UtilityFunctions::randf() * 0.5f,
        0.5f + UtilityFunctions::randf() * 0.5f
    );
    
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
    return mesh_instances.size() * triangles_per_object;
}

int GPUBasicsScene::get_object_count() const {
    return mesh_instances.size();
}

