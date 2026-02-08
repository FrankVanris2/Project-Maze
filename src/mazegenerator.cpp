#include "mazegenerator.h"

using namespace godot;

void MazeGenerator::_bind_methods() {
    // We will register functions here later
}

MazeGenerator::MazeGenerator() : g(rd()) {
    // Constructor logic
    srand(time(0));
    width = randomIntCreator();
    height = randomIntCreator();
    maze.resize(height, std::vector<int>(width, 0));

    for(int i = 0; i < height; ++i) {
        for(int j = 0; j < width; ++j) {
            maze[i][j] = 1; // Initialize all cells as walls (1)
        }
    }

    start_x = (rand() % (width / 2)) * 2 + 1; // Ensure start_x is odd
    start_y = (rand() % (height / 2)) * 2 + 1; // Ensure start_y is odd
    if (start_x % 2 == 0) start_x += 1;
    if (start_y % 2 == 0) start_y += 1;

    generateMaze();
}

MazeGenerator::~MazeGenerator() {
    // Destructor logic
}

int MazeGenerator::randomIntCreator() {
    // Generates a random integer that is odd for both width and height
    int min = 21;
    int max = 51;
    int randomNum = rand() % (max - min + 1) + min;
    if (randomNum % 2 == 0) {
        randomNum += 1; // Ensuring that the number is odd
    }
    return randomNum;
}

void MazeGenerator::generateMaze() {
    generateRecursive(start_x, start_y);

    // Create 4 exits in the maze.
    createExits();

    // Render the maze in the Godot scene
    renderMaze();
}

void MazeGenerator::generateRecursive(int x, int y) {
    maze[y][x] = 0; // Mark the current cell as a path (0);
    std::vector<std::pair<int, int>> directions = {{0, -2}, {0, 2}, {-2, 0}, {2, 0}}; // Up, Down, Left, Right
    
    
    std::shuffle(directions.begin(), directions.end(), g);

    for (const auto& dir : directions) {
        int new_x = x + dir.first;
        int new_y = y + dir.second; 
        if (new_x >= 0 && new_x < width && new_y >= 0 && new_y < height && maze[new_y][new_x] == 1) {
            maze[y + dir.second / 2][x + dir.first / 2] = 0; // Remove the wall between the current cell and the new cell
            generateRecursive(new_x, new_y); // Recur with the new cell
        }
    }
}

// Creating 4 random exits on the borders of the maze
void MazeGenerator::createExits() { 
    // Logic for a random North exit
    int rand_x = (rand() % ((width - 1) / 2)) * 2 + 1; // Random odd x coordinate
    maze[0][rand_x] = 0; // Create an exit on the North border
    maze[1][rand_x] = 0; // Ensure the exit is connected to the maze

    // Logic for a random South exit
    rand_x = (rand() % ((width - 1) / 2)) * 2 + 1; // Random odd x coordinate
    maze[height - 1][rand_x] = 0; // Create an exit on the South border
    maze[height - 2][rand_x] = 0; // Ensure the exit

    // Logic for a random West exit
    int rand_y = (rand() % ((height - 1) / 2)) * 2 + 1; // Random odd y coordinate
    maze[rand_y][0] = 0; // Create an exit on the West border
    maze[rand_y][1] = 0; // Ensure the exit is connected to the maze

    // Logic for a random East exit
    rand_y = (rand() % ((height - 1) / 2)) * 2 + 1; // Random odd x coordinate
    maze[rand_y][width - 1] = 0; // Create an exit on the East border
    maze[rand_y][width - 2] = 0; // Ensure the exit is connected to the maze

}

// The rendering of the Maze in the Godot scene.
void MazeGenerator::renderMaze() {

    // Wall render
    Ref<BoxMesh> wall_mesh;
    wall_mesh.instantiate();
    float wall_height = 8.0f;
    wall_mesh->set_size(Vector3(1, wall_height, 1));

    // Floor render
    Ref<BoxMesh> floor_mesh;
    floor_mesh.instantiate();
    float floor_thickness = 0.1f;
    floor_mesh->set_size(Vector3(1, floor_thickness, 1));

    for(int y = 0; y < height; y++) {
        for(int x = 0; x < width; x++) {

            // 1. Create the Instance (The "Node" in the tree)
            MeshInstance3D *instance = memnew(MeshInstance3D);
            if (maze[y][x] == 1) {
                // SPAWN WALL
                instance->set_mesh(wall_mesh);
                instance->set_position(Vector3(x, wall_height / 2.0f, y));
            } else {
                // SPAWN FLOOR
                instance->set_mesh(floor_mesh);
                // Position floor slightly below 0 so it doesn't "flicker" with the ground
                instance->set_position(Vector3(x, -floor_thickness / 2.0f, y));
            }

            add_child(instance);
        }
    }
}