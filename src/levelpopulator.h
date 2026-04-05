#ifndef LEVELPOPULATOR_H
#define LEVELPOPULATOR_H

#include <godot_cpp/classes/marker3d.hpp>
#include <cmath>
#include <cstdlib>
#include <vector>

#include "mazegenerator.h"

namespace godot {

class LevelPopulator {
public:
    // The main execution function
    static void populate(MazeGenerator* maze_node);

private:
    static void createSpawnPoints(MazeGenerator* maze_node);
    static void tagExits(MazeGenerator* maze_node);
    static void createKeySpawns(MazeGenerator* maze_node);
};
}
#endif