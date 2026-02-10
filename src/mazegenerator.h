#ifndef MAZEGENERATOR_H
#define MAZEGENERATOR_H
#include <godot_cpp/classes/node3d.hpp>
#include <godot_cpp/classes/mesh_instance3d.hpp>
#include <godot_cpp/classes/box_mesh.hpp>
#include <godot_cpp/classes/standard_material3d.hpp>
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

private: 
    std::vector<std::vector<int>> maze; 
    int width;
    int height;
    
    int start_x;
    int start_y;

    std::random_device rd;
    std::mt19937 g;
    int randomIntCreator();

    // Maze generation functions
    void generateMaze();
    void generateRecursive(int x, int y);
    void createExits();

    // Maze rendering function
    void renderMaze();

};
}

#endif // MAZEGENERATOR_H