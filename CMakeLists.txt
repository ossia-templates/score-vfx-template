cmake_minimum_required(VERSION 3.13 FATAL_ERROR)

if(NOT TARGET score_lib_base)
  include(ScoreExternalAddon)
endif()

if(NOT TARGET score_plugin_gfx)
  message("Requires gfx plug-in")
  return()
endif()

project(score_addon_my_vfx LANGUAGES CXX)

# General initialization
score_common_setup()

# Creation of the library
add_library(score_addon_my_vfx
  MyVfx/Executor.hpp
  MyVfx/Metadata.hpp
  MyVfx/Process.hpp
  MyVfx/Layer.hpp
  MyVfx/Executor.cpp
  MyVfx/Process.cpp
  MyVfx/Node.hpp
  MyVfx/Node.cpp

  score_addon_my_vfx.hpp
  score_addon_my_vfx.cpp
)

# Link
target_link_libraries(score_addon_my_vfx PUBLIC
  score_plugin_gfx
  score_plugin_engine
)

# Target-specific options
setup_score_plugin(score_addon_my_vfx)

