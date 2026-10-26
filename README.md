# ScheduleApp

[![Build](https://github.com/madkitzune/ScheduleApp/actions/workflows/build.yml/badge.svg)](https://github.com/madkitzune/ScheduleApp/actions/workflows/build.yml)

Desktop app for managing a class schedule, written in C++17 with Qt 6 (Qt Quick / QML). Coursework project.

## Features

- Load and save a schedule as a text file or an SQLite database
- View the schedule as a table, sort it, insert, replace and delete records
- Statistics page for the loaded schedule

## Data format

One record per line, fields separated by `|`:

```
subject|startHHMM|room|teacher|durationMin
```

`input1.txt` and `input2.txt` are sample schedules.

## Build

Requirements: Qt 6 with the Quick and Sql modules, CMake 3.16 or newer.

```bash
cmake -B build -DCMAKE_PREFIX_PATH=<path-to-Qt>/6.x/<compiler>
cmake --build build
```

Or open `CMakeLists.txt` in Qt Creator.

## CI

GitHub Actions builds the app on Linux and Windows on every push. The Windows job bundles the Qt runtime with `windeployqt` and uploads a ready-to-run build as an artifact.

## Structure

```
main.cpp             app entry point, registers ScheduleModel for QML
schedule.h/.cpp      schedule record and file operations
schedulemodel.h/.cpp Qt table model: TXT and SQLite load/save, sort, edit, stats
qml/                 pages and UI components
```
