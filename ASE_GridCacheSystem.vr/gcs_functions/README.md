# Grid Caching System- GCS

Exceåt unit from caching:
this setVariable ["UseGrid", False]; 

[![N|Solid](https://i.imgur.com/x37NfvT.png)](https://i.imgur.com/x37NfvT.png)

Grid Caching System (GCS) is a system where the objective is to allow missions creators to use more intensively vehicles and AI with a lower impact on performance by dynamically spawning these.
Optionally, a persistence system is also integrated with GCS.

# Features

  - Dynamic grid allowing better performances by caching unused AI or vehicles
  - Integrated persistence system (optionnal)

# How it works

GCS adds a grid to the field based on three configurable parameters:

    GCS_VAR_SIZE_SQUARE_GRID            - Represents the total size of each grid
    GCS_VAR_SIZE_ACTIVATION_SQUARE_GRID - Represents the trigger distance where AIs and vehicles will be created
    GCS_VAR_SIZE_UNSPAWN_SQUARES        - Represents the trigger distance where AIs and vehicles will be cached and removed

Here is a simple 2D visual representation of a single grid square:
[![N|Solid](https://i.imgur.com/QpyUlN9.png)](https://i.imgur.com/QpyUlN9.png)

All the AI units and vehicles inside the black square will be spawned if one or more player enter the red square (activation area). If all the players leaves the blue square (unspawn area), then all the AI units and vehicles in the black square will be cached and unspawned.

Ideally, the distance between GCS_VAR_SIZE_SQUARE_GRID and GCS_VAR_SIZE_ACTIVATION_SQUARE_GRID must be large enough to prevent the player from seeing the spawn of AI units and objects, this will depend heavly on type of map though. Also, the distance between GCS_VAR_SIZE_ACTIVATION_SQUARE_GRID and GCS_VAR_SIZE_UNSPAWN_SQUARES must be large enough too to avoid players spawning and unspawning the AI units and vehicles all the time (or cause a potentially problematic desynchronisation between the cached data and the spawned data).

### Persistence

By default, GCS will use in-memory caching, this means that all the data will simply be stored in local array.
This can be used as long as your usage of this system is link to the mission life time (ie. until the mission is changed or the server shutdown). However if you want to add persistent data caching, then you can use the database system that is proposed with GCS. This "simple" switch simply will store all the in-memory array in a database table.

This will allow the system to retrieve the cached data even after a server shutdown, mission change. This can be very helpfull if your mission is designed to have a long duration (ie. survival mods, liberation-like mission, ...).

If your mission already use a database, then you can simply add a new table into it and get started, very non-intrusive!

## Installation

1. Download the latest release 
2. Copy the /gcs_functions folder into your mission root directory. (ie. /MyMission.Stratis/)
3. Copy the following files into your mission root directly :
3.1 GCS_configServer.sqf
3.2 initGridCachingSystem.sqf
4. Copy the content of the initServer.sqf in your own initServer.sqf. The content idealy must be at the begining of the file. (if you don't have this file already, just copy the file in the root directory of your mission).
5. Play!

## Additionnal configuration
#### Grid configuration
You can adapt the size of the different sizes of each square grid parameter in the initGridCachingSystem.sqf:
// Grid cells parameters
GCS_VAR_SIZE_SQUARE_GRID = 500;
GCS_VAR_SIZE_ACTIVATION_SQUARE_GRID = 1500;
GCS_VAR_SIZE_UNSPAWN_SQUARES = 2000;