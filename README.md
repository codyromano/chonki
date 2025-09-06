# Chonki

*Instructions for LLMs:*

## Summary

Chonki is a 2D side-scroller game about a lost dog searching for his owner. It is written in GDScript for the Godot engine, version 4.2. The game will be deployed for desktop Web.

## Goals

1. Primary: Navigate the corgi through a series of obstacles to find his owner, avoiding hazards such as geese and bicyclists.

2. Secondary: Gather "books," an in-game collectible, and complete the level quickly. Each book reveals part of the storyline.

## Scoring

The player receives an overall ranking for each level: okay, great, or perfect. The ratings are based on how many books the player collected and how much time they spent in the level.

The total # of books varies by level. Find it by counting the number of "Collectible" nodes in a level where the "Collectible Name" is "star." The number of collected books is tracked in res://scenes/StarLabel.gd.

Note: "star" is a legacy name for book.

### Okay

1. Survive the level and find your owner.
2. Complete the level in under 90 seconds

### Great

1. Survive the level and find your owner
2. Complete the level in under 80 seconds
3. Collect 50% of stars.

### Perfect 

1. Survive the level and find your owner
2. Complete the level in under 60 seconds
3. Collect 100% of stars

## Health

The player has three lives for each scene, which are displayed as heart icons within the HUD node. The player loses lives by colliding with certain hazards such as geese. The current number of hearts is stored within HUDControl.gd.

After losing three lives, the Chonki character (Chonki.gd) plays a "sleep" animation for its child AnimatedSprite2D. Meanwhile, the rest of the screen freezes. After 4 seconds, the screen fades to black, then the level restarts with its state reset.

## Scene Transition System

The game implements a stateful scene caching system to preserve complete runtime state when transitioning between scenes (e.g., intro ↔ library).

### SceneStack Pattern

**Location**: `res://scripts/SceneStack.gd` (autoload singleton)

The SceneStack maintains an array of cached scenes that preserves ALL runtime state including:
- Node positions, velocities, and physics states
- Variable values and object properties  
- Animation states and timers
- UI state and player progress

**Key Methods**:
- `push_scene(packed_scene)`: Caches current scene (disabled but not freed) and loads new scene
- `pop_scene()`: Restores previous scene from cache with complete state intact
- `clear_cache()`: Frees all cached scenes (use when returning to main menu)

**Critical Implementation Details**:
- Cached scenes are **disabled** (`process_mode = PROCESS_MODE_DISABLED`) but NOT freed
- Scene nodes remain in memory with all properties preserved
- `_ready()` is NOT called when scenes are restored from cache
- Maximum cache size configurable via `max_cached_scenes` export variable

### Scene Transition Controller

**Location**: `res://scripts/scene_transition_controller.gd` (attached to intro.tscn only)

Handles fade transitions and library access. **IMPORTANT**: This controller exists as a scene-specific node, NOT an autoload singleton.

**Key Features**:
- Fade overlay management with CanvasLayer (layer 100)
- Transition state protection via `is_transitioning` boolean flag
- Automatic fade clearing when scenes are restored
- Player re-registration for audio system (see Player Registration below)

**Critical Debugging Notes**:
- If multiple transitions occur, check for duplicate controller instances
- Controller should ONLY be attached to intro.tscn, not registered as autoload
- Library entry signal (`enter_little_free_library`) includes protection against multiple emissions

### Player Registration System

**Problem Solved**: Audio nodes become disconnected when scenes are restored from SceneStack because `_ready()` doesn't re-execute.

**Implementation**:
- `GlobalSignals.player_registered` / `player_unregistered` signals manage audio node references
- `ChonkiAudioController.gd` (autoload) listens for registration signals
- Player emits registration in `_ready()` and unregistration in `_exit_tree()`
- **Scene restoration fix**: `scene_transition_controller.clear_fade()` automatically re-emits player registration

**Code Locations**:
- Registration emission: `chonki.gd` lines 47 and 317
- Signal handling: `ChonkiAudioController.gd` 
- Re-registration: `scene_transition_controller.gd` in `clear_fade()` method

**LLM Debugging Guide**:
- If audio stops working after scene transitions, check player registration signals
- Look for "Re-registering player for audio" console message when returning from library
- Ensure `ChonkiAudioController` receives both registration and unregistration signals

### Library Interaction

**Location**: `res://scenes/LittleFreeLibrary.gd`

**Signal Protection**: Uses `has_entered_library` boolean to prevent multiple signal emissions per visit. Flag resets when player exits library area.

**Input Handling**: Responds to "read" action (`Input.is_action_just_pressed("read")`) only when player is standing at library AND hasn't already entered.

## Coding Conventions

- Don't add comments

- All signals live in `GlobalSignals.gd`

- Use null checks only when required. Always assume that any node or resource exists if it is present in the scene tree or code, unless you know that it is created conditionally.

- **Use the modern signal connection syntax.** When connecting signals, prefer the modern callable syntax: GlobalSignals.connect("some_signal", _on_some_signal)
