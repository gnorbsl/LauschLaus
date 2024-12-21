cmake_minimum_required(VERSION 3.16)
project(KidsPlayer VERSION 1.0)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick)

qt_add_executable(KidsPlayer
    main.cpp
)

qt_add_qml_module(KidsPlayer
    URI KidsPlayer
    VERSION 1.0
    QML_FILES
        main.qml
)

target_link_libraries(KidsPlayer PRIVATE
    Qt6::Quick
) 