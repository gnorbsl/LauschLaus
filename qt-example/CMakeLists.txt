cmake_minimum_required(VERSION 3.1)
project(KidsPlayer VERSION 1.0)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

# Find Qt5 packages
find_package(Qt5 COMPONENTS Core Quick Gui REQUIRED)

# Add platform-specific configuration
if(UNIX AND NOT APPLE)
    add_definitions(-DQT_QPA_PLATFORM=linuxfb)
    add_definitions(-DQT_QPA_FB_NO_LIBINPUT=1)
    add_definitions(-DQT_QPA_GENERIC_PLUGINS="evdevtouch:/dev/input/event0")
endif()

# Include Qt directories
include_directories(${Qt5Core_INCLUDE_DIRS}
                  ${Qt5Quick_INCLUDE_DIRS}
                  ${Qt5Gui_INCLUDE_DIRS})

# Add executable
add_executable(KidsPlayer
    main.cpp
)

# Link Qt5 libraries
target_link_libraries(KidsPlayer
    Qt5::Core
    Qt5::Quick
    Qt5::Gui
) 