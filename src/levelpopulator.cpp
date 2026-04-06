#include "levelpopulator.h"

using namespace godot;

void LevelPopulator::populate(MazeGenerator* maze_node) {
    createSpawnPoints(maze_node);
    tagExits(maze_node);
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

void LevelPopulator::tagExits(MazeGenerator* maze_node) {
    std::vector<std::pair<int, int>> exits;
    int w = maze_node->getWidth();
    int h = maze_node->getHeight();

    // Scan the borders to find where the MazeGenerator carved the 4 exits (0s)
    for(int x = 1; x < w - 1; ++x) if(maze_node->get_cell(x, 0) == 0) exits.push_back({x, 0});
    for(int x = 1; x < w - 1; x++) if(maze_node->get_cell(x, h - 1) == 0) exits.push_back({x, h - 1});
    for(int y = 1; y < h - 1; y++) if(maze_node->get_cell(0, y) == 0) exits.push_back({0, y});
    for(int y = 1; y < h - 1; y++) if(maze_node->get_cell(w - 1, y) == 0) exits.push_back({w - 1, y});

    if (exits.empty()) return;

    // Drop a marker for EVERY exit found, all tagged as real doors
    for (size_t i = 0; i < exits.size(); ++i) {
        Marker3D *door_marker = memnew(Marker3D);
        door_marker->set_position(Vector3(exits[i].first, 0.0f, exits[i].second));
        door_marker->add_to_group("exit_door");
        maze_node->add_child(door_marker);
    }
}