# Kayak Float Tests

## Overview
This directory contains unit tests for the kayak floating and rotation mechanics.

## Test File
- `test_kayak_float.gd` - Comprehensive tests for the kayak_float.gd script

## Running Tests

### Prerequisites
1. Install GUT (Godot Unit Test) addon from the AssetLib or GitHub:
   - https://github.com/bitwes/Gut
   
2. Or use Godot's built-in testing (if available in your version)

### With GUT
1. Install GUT addon to `res://addons/gut/`
2. Enable the GUT plugin in Project Settings
3. Run tests via:
   - Scene: Open `res://addons/gut/GutRunner.tscn` and run
   - Command line: `godot --path . -d -s addons/gut/gut_cmdln.gd`
   - Editor: Use the GUT panel in the bottom panel

### Alternative: Manual Testing
You can also manually verify the kayak behavior:
1. Open `scenes/level1.tscn`
2. Run the scene
3. Navigate to the kayak
4. Test standing on left/right sides to verify rotation
5. Verify the floating motion

## Test Coverage

### Floating Motion Tests
- ✅ Initial state (zero rotation, stored position)
- ✅ Vertical floating motion (quadratic)
- ✅ Respects amplitude parameter
- ✅ Continuous floating over multiple cycles

### Rotation Tests
- ✅ Rotates left (counterclockwise) when player on left
- ✅ Rotates right (clockwise) when player on right
- ✅ Rotation accelerates over time
- ✅ Balances when player on both sides
- ✅ Returns to level when player leaves
- ✅ Flip detection at 180 degrees

### Player Detection Tests
- ✅ Detects player by name containing "Chonki"
- ✅ Detects player in "player" group
- ✅ Ignores non-player bodies

### Configuration Tests
- ✅ All export variables are accessible
- ✅ Rotation velocity initializes to zero

## Test Structure
Each test follows the pattern:
1. `before_each()` - Sets up fresh kayak instance and mock player
2. Individual test function - Tests specific behavior
3. `after_each()` - Automatic cleanup with autofree

## Expected Behavior
- **Floating**: Kayak bobs up and down using quadratic motion
- **Rotation**: Accelerates continuously when player on one side
- **Balance**: Slows rotation when player centered or on both sides
- **Flip**: Marks as flipped at 180 degrees
- **Recovery**: Returns to level when no player weight

## Adjustable Parameters Tested
- `float_amplitude` - Height of floating motion
- `float_speed` - Speed of floating cycle
- `rotation_acceleration` - How fast rotation speeds up (1.25 = 2.5x base)
- `flip_angle` - Angle at which flip occurs (180.0 degrees)
- `return_speed` - Speed of return to level position
