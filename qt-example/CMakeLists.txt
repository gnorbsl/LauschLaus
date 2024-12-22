cmake_minimum_required(VERSION 3.1)
project(KidsPlayer VERSION 1.0)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)

# Find Qt5 packages
find_package(Qt5 COMPONENTS Core Quick REQUIRED)

# Add executable
add_executable(KidsPlayer
    main.cpp
)

# Link Qt5 libraries
target_link_libraries(KidsPlayer
    Qt5::Core
    Qt5::Quick
) 