cmake_minimum_required(VERSION 3.16)
project(ScheduleApp VERSION 1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

find_package(Qt6 REQUIRED COMPONENTS Quick Sql)

qt_add_executable(ScheduleApp
    main.cpp
    schedule.h
    schedule.cpp
    schedulemodel.h
    schedulemodel.cpp
    qml.qrc
)

target_link_libraries(ScheduleApp
    PRIVATE
    Qt6::Quick
    Qt6::Sql
)

set_target_properties(ScheduleApp PROPERTIES
    WIN32_EXECUTABLE TRUE
    MACOSX_BUNDLE TRUE
)
