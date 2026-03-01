#include "mazegenerator.h"

using namespace godot;

void MazeGenerator::_bind_methods() {
    // We will register functions here later
}

MazeGenerator::MazeGenerator() : g(rd()) {
    // Constructor logic
    srand(time(0));    
}

MazeGenerator::~MazeGenerator() {
    // Destructor logic
}

void MazeGenerator::_ready() {
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

int MazeGenerator::randomIntCreator() {
    // Generates a random integer that is odd for both width and height
    int min = 51;
    int max = 81;
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

    center_x = width / 2;
    center_y = height / 2;

    if (center_x % 2 == 0) center_x++;
    if (center_y % 2 == 0) center_y++;

    offset = 3;

    createCenterRoom(center_x, center_y, offset);

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

void MazeGenerator::createCenterRoom(int center_x, int center_y, int offset) {  
    // Create a 3x3 room in the center of the maze
    for (int y = center_y - offset; y <= center_y + offset; ++y) {
        for (int x = center_x - offset; x <= center_x + offset; ++x) {
            if (x >= 0 && x < width && y >= 0 && y < height) {
                maze[y][x] = 0; // Mark the cell as a path (0)
            }
        }
    }

    maze[center_y - 3][center_x] = 0; // North Door
    maze[center_y + 3][center_x] = 0; // South Door
}

// The rendering of the Maze in the Godot scene.
void MazeGenerator::renderMaze() {
    // 1. Create Wall Material (Dark Red/Stone) NOTE: Create these as functions later
    Ref<StandardMaterial3D> wall_mat;
    wall_mat.instantiate();
    wall_mat->set_albedo(Color(0.5, 0.2, 0.15)); // A deep crimson
    wall_mat->set_roughness(0.8); // High roughness for a stone-like appearance
    
    // 2. Create Floor Material (Dark Grey/ Slate)
    Ref<StandardMaterial3D> floor_mat;
    floor_mat.instantiate();
    floor_mat->set_albedo(Color(0.1, 0.1, 0.1)); // Near black


    // Wall render
    Ref<BoxMesh> wall_mesh;
    wall_mesh.instantiate();
    float wall_height = 8.0f;
    wall_mesh->set_size(Vector3(1, wall_height, 1));

    // Floor render
    Ref<BoxMesh> floor_mesh;
    floor_mesh.instantiate();
    float floor_thickness = 2.0f;
    floor_mesh->set_size(Vector3(1, floor_thickness, 1));

    for(int y = 0; y < height; y++) {
        for(int x = 0; x < width; x++) {

            // 1. Create the Instance (The "Node" in the tree)
            MeshInstance3D *instance = memnew(MeshInstance3D);
            if (maze[y][x] == 1) {
                // SPAWN WALL
                instance->set_mesh(wall_mesh);
                instance->set_position(Vector3(x, wall_height / 2.0f, y));
                instance->set_material_override(wall_mat);
            } else {
                // SPAWN FLOOR
                instance->set_mesh(floor_mesh);
                // Position floor slightly below 0 so it doesn't "flicker" with the ground
                instance->set_position(Vector3(x, -floor_thickness / 2.0f, y));
                instance->set_material_override(floor_mat);
            }
            
            // 1. Create a StaticBody (The physics object)
            StaticBody3D *static_body = memnew(StaticBody3D);
            instance->add_child(static_body); // Add it to our mesh instance

            // 2. Create a CollisionShape (The "hitbox")
            CollisionShape3D *collision_shape = memnew(CollisionShape3D);
            static_body->add_child(collision_shape);

            // 3. Create the actual Shape geometry (A Box)
            Ref<BoxShape3D> box;
            box.instantiate();
            
            if (maze[y][x] == 1) {
                box->set_size(Vector3(1, wall_height, 1));
            } else {
                box->set_size(Vector3(1, floor_thickness, 1));
            }
            
            collision_shape->set_shape(box);
            add_child(instance);
        }
    }
}

