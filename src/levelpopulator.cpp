#include "levelpopulator.h"

using namespace godot;

void LevelPopulator::populate(MazeGenerator* maze_node) {
    createSpawnPoints(maze_node);
    // tagExits(maze_node);
    // createKeySpawns(maze_node);
}

void LevelPopulator::createSpawnPoints(MazeGenerator* maze_node) {
    float radius = 2.5f;
    for (int i = 0; i < 10; ++i) {
        float angle = i * (2.0f * 3.14159265f / 10.0f);
        float x_offset = std::cos(angle) * radius;
        float z_offset = std::sin(angle) * radius;

        Marker3D * spawn_marker = memnew(Marker3D);
        spawn_marker->set_position(Vector3(maze_node->getCenterX() + x_offset, 0.0f, maze_node->getCenterY() + z_offset));
        spawn_marker->add_to_group("spawn_points");
        maze_node->add_child(spawn_marker);
    }
}