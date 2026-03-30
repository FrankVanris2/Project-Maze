#ifndef MAZEGENERATOR_H
#define MAZEGENERATOR_H
#include <godot_cpp/classes/node3d.hpp>
#include <godot_cpp/classes/mesh_instance3d.hpp>
#include <godot_cpp/classes/box_mesh.hpp>
#include <godot_cpp/classes/standard_material3d.hpp>
#include <godot_cpp/classes/static_body3d.hpp>
#include <godot_cpp/classes/collision_shape3d.hpp>
#include <godot_cpp/classes/box_shape3d.hpp>
#include <godot_cpp/classes/marker3d.hpp>
#include <vector>
#include <stdlib.h>
#include <time.h>
#include <algorithm> // For std::shuffle
#include <random> // For std::mt19937 and std::random_device


namespace godot {

class MazeGenerator : public Node3D {
    GDCLASS(MazeGenerator, Node3D)

protected:
    static void _bind_methods();

public: 
    MazeGenerator();
    ~MazeGenerator();
    void _ready() override;


private: 
    std::vector<std::vector<int>> maze; 
    int width;
    int height;
    
    int start_x;
    int start_y;

    int center_x;
    int center_y;
    int offset;

    std::random_device rd;
    std::mt19937 g;
    int randomIntCreator();

    // Maze generation functions
    void generateMaze();
    void generateRecursive(int x, int y);
    void createExits();
    void createCenterRoom(int center_x, int center_y, int offset);

    // Maze rendering function
    void renderMaze();

};
}

#endif // MAZEGENERATOR_H