# Arma 3 Chair Sitting System Documentation
Author: Emek1501

## Overview
This system provides a comprehensive solution for allowing players to sit on various chair objects in Arma 3 using ACE interaction menu. The system includes position adjustments, animations, and proper synchronization across the network.

## File Structure
```
mission_root/
├── description.ext
├── init.sqf
└── functions/
    ├── config/
    │   └── fn_initSitting.sqf
    ├── sitting/
    │   ├── fn_addSitActions.sqf
    │   ├── fn_canSit.sqf
    │   ├── fn_canStand.sqf
    │   ├── fn_sit.sqf
    │   ├── fn_stand.sqf
    │   └── fn_getRandomAnimation.sqf
    └── helper/
        └── fn_switchAnimation.sqf
```

## Core Components

### Configuration (description.ext)
- Defines basic mission parameters
- Sets up function declarations via CfgFunctions
- Contains CfgSitting class with chair configurations
- Configures ACE requirements and settings
- Initializes the system via PostInit event handler

### Initialization (fn_initSitting.sqf)
- Runs once at mission start
- Processes chair configurations from CfgSitting
- Creates list of valid chair classes
- Adds sit actions to all configured chair types

## Key Functions

### Action Management
**fn_addSitActions.sqf**
- Creates ACE interaction menu actions for chairs
- Adds actions to both class definitions and existing objects
- Includes condition checks and proper action setup

### Condition Checks
**fn_canSit.sqf**
- Verifies if a player can sit in a specific chair
- Checks for chair occupation and player sitting status
- Returns boolean result

**fn_canStand.sqf**
- Checks if a player is currently sitting
- Verifies ability to perform stand action
- Returns boolean result

### Animation Handling
**fn_getRandomAnimation.sqf**
- Provides random sitting animations from predefined list
- Includes various idle and movement animations
- Supports different sitting styles and positions

**fn_switchAnimation.sqf**
- Handles smooth animation transitions
- Uses both switchMove and playMoveNow for reliability
- Includes error checking and logging

### Core Sitting Functions
**fn_sit.sqf**
- Main sitting functionality implementation
- Handles:
  * Position attachment
  * Direction setting
  * Animation application
  * Camera adjustments
  * Variable management
  * ACE interaction updates
  * Continuous monitoring via PFH
- Includes network synchronization
- Manages edge cases and error conditions

**fn_stand.sqf**
- Handles complete standing up process
- Manages:
  * Variable cleanup
  * Animation transitions
  * Camera restoration
  * Interaction menu updates
  * Position reset
- Selects appropriate standing animation based on weapon state

## Chair Configuration
Chairs are configured in description.ext under CfgSitting:
```sqf
class ChairTypes {
    class ChairClassName {
        canSit = 1;
        sitPosition[] = {x, y, z};
        sitDirection = degree;
    };
}
```

### Configuration Parameters
- canSit: Enable/disable sitting (1/0)
- sitPosition: Offset from chair origin [X, Y, Z]
- sitDirection: Rotation offset in degrees

## Network Considerations
- Uses remoteExec for animation synchronization
- Variables marked for network synchronization where needed
- Checks for local execution and redirects as required

## Dependencies
- ACE Interaction Menu
- ACE Common
- CBA Functions (for PFH)

## Error Handling
- Input validation on all functions
- Extensive debug logging
- Proper variable cleanup
- Chair deletion handling
- Network synchronization verification

## Usage Example
To add a new chair type:
1. Add configuration to CfgSitting in description.ext
2. Ensure proper offset values
3. Chair will automatically be initialized at mission start

## Common Issues and Solutions
1. Floating Animations
   - Adjust sitPosition values in chair configuration
2. Wrong Facing Direction
   - Modify sitDirection value in configuration
3. Network Sync Issues
   - Verify remoteExec usage
   - Check variable synchronization

## Best Practices
1. Always test new chair configurations
2. Use debug logging during development
3. Consider network impact with many chairs
4. Clean up variables properly
5. Handle edge cases (chair deletion, etc.)

## Future Improvements
Potential enhancements could include:
- Additional animation sets
- Dynamic position adjustment
- Chair-specific animations
- Enhanced error handling
- Performance optimizations