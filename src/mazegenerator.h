#ifndef MAZEGENERATOR_H
#define MAZEGENERATOR_H
#include <godot_cpp/classes/node3d.hpp>

namespace godot {

class MazeGenerator : public Node3D {
    GDCLASS(MazeGenerator, Node3D)

protected:
    static void _bind_methods();

public: 
    MazeGenerator();
    ~MazeGenerator();
};
}

#endif // MAZEGENERATOR_H