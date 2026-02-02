#!/usr/bin/env python

import os
import sys 

# Tell SCons where the Godot C++ bindings are
env = DefaultEnvironment(tools=['default'])

env.Append(CPPFLAGS=['/std:c++17'])

env.Append(CPPPATH=['src/', 'godot-cpp-master/include', 'godot-cpp-master/gen/include', 'godot-cpp-master/gdextension'])


# Fixing linker issue by telling SCons where the .lib files are 
env.Append(LIBPATH=['godot-cpp-master/bin'])

# Also tells which library to link against
env.Append(LIBS=['libgodot-cpp.windows.template_debug.x86_64'])


# Set up the platform-specific settings (windows)
if sys.platform == 'win32':
    env.Append(CPPDEFINES=['WIN32', '_WIN32', '_WINDOWS'])
    
# Identity your source files
sources = Glob('src/*.cpp')

# This creates the dynamic library (.dll)
library = env.SharedLibrary( 
    'bin/maze_game_library', # The name of my output file
    source=sources,
)

Default(library)