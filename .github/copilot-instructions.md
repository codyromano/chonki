# Chonki - AI Coding Agent Instructions

## Project Overview
Chonki is a 2D side-scroller built with **Godot 4.2+** and **GDScript** about a lost corgi searching for his owner. The game features physics-based movement, collectibles (books/stars), quest systems, and scene-based progression.

## Critical Architecture Patterns

### Singleton Autoload System
All global systems use Godot autoloads (defined in `project.godot`):
- **`GlobalSignals`** (`scenes/GlobalSignals.gd`) - ALL signals must live here. Never create signals in individual scripts.
- **`SceneStack`** (`scripts/SceneStack.gd`) - Stateful scene caching with complete runtime preservation
- **`GameState`** - Level progression, star counts, time tracking
- **`PlayerInventory`** - Enum-based inventory with type safety
- **`PhysicsConstants`** - All movement/physics values (NEVER hardcode physics values)
- **`AnimationConstants`** - Animation timing constants

### Scene Caching & State Preservation
**Critical**: Scenes are cached and restored, NOT reloaded. `_ready()` does NOT fire when popping back to cached scenes.

**Pattern**: `SceneStack.push_scene()` disables current scene (`PROCESS_MODE_DISABLED`) but keeps it in memory with ALL state intact (positions, velocities, timers, variables). Use `SceneStack.pop_scene()` to restore.

**Player Audio Re-registration**: When restoring scenes, audio nodes lose references because `_ready()` doesn't re-execute. Fix: `scene_transition_controller.gd`'s `clear_fade()` manually re-emits `GlobalSignals.player_registered` (see lines 29-36). This happens silently without console output.

### Signal Architecture
**Rule**: All signals in `GlobalSignals.gd`. Use modern callable syntax:
```gdscript
GlobalSignals.connect("player_hit", _on_player_hit)
GlobalSignals.player_hit.emit()
```

**Critical Pattern**: Prefer using `GlobalSignals` to connect disparate components instead of traversing the scene tree with `get_node()` or `find_child()`. This decouples components and makes them more reusable.

**When to use signals vs NodePaths**:
- ✅ **Use GlobalSignals**: When components are in different parts of the scene tree or need loose coupling (e.g., Rodrigo pickup triggering wall fade)
- ✅ **Use @export NodePath or direct children access**: Only when a script modifies its own direct/shallow children (e.g., a parent node accessing `$ChildSprite` or `$ChildCollision`)
- ❌ **Avoid**: Deep NodePath traversal like `../../Platforms/SomeNode` - this creates brittle dependencies and breaks when scene structure changes

**Example**: `rodrigo_enclosure_wall.gd` listens to `GlobalSignals.rodrigo_picked_up` instead of Rodrigo trying to find wall nodes with complex NodePaths. Each wall script independently handles the signal and manages its own fade/removal.

Common signals:
- `player_hit` / `player_out_of_hearts` / `heart_lost` - Health system
- `star_collected` - Collectible tracking
- `player_registered` / `player_unregistered` - Audio system sync
- `enter_little_free_library` - Scene transition trigger
- `set_chonki_frozen` - Disable player input during cutscenes
- `spawn_item_in_location(PlayerInventory.Item)` - Quest rewards

### Physics & Movement
**Always reference `PhysicsConstants.gd`** - never hardcode:
- `SPEED`, `MAX_SPEED`, `ACCELERATION`, `DECELERATION`
- `JUMP_FORCE`, `GRAVITY`, `MAX_FALL_SPEED`
- `SLIDE_THRESHOLD`, `HIT_RECOVERY_TIME`

Movement is acceleration-based (see `scenes/chonki.gd`). Speed increases over time held, capped at `MAX_SPEED`.

**Midair jumps**: `grown_up_chonki.gd` supports `@export var midair_jumps: int = 0`. Each midair jump triggers 0.5s backflip animation with unique SFX, tracked via `is_backflipping` flag. Midair jumps are essential for puzzle design in `level1.tscn` and planned for `intro.tscn`.

### Inventory & Quest System
**PlayerInventory**: Enum-based with type safety:
```gdscript
enum Item { POTTERY_1, POTTERY_2, POTTERY_3, SECRET_LETTER_X, MOMO_QUEST }
PlayerInventory.add_item(PlayerInventory.Item.POTTERY_1)
if PlayerInventory.has_item(PlayerInventory.Item.MOMO_QUEST):
```

**SpawnLocation pattern** (`scenes/spawn_location.tscn`):
- Marker2D nodes with invisible children
- Set `@export var item_name` to match `PlayerInventory.Item` enum
- Listen for `GlobalSignals.spawn_item_in_location.emit(item)` to reveal
- Use `auto_spawn = true` to bypass signal requirement

## Scene Structure Conventions

### Node Naming
- Player character body: **`ChonkiCharacter`** (CharacterBody2D)
- Main player node: **`Chonki`** (Node2D parent)
- HUD nodes: Add to **`HUDControl`** group
- Collectibles named "star": Auto-added to **`CollectibleStar`** group

### Scene Hierarchy
```
Chonki (Node2D)
├── ChonkiCharacter (CharacterBody2D)
│   ├── AnimatedSprite2D
│   ├── CollisionShape2D
│   └── Camera2D
└── ChonkiSpriteController (AnimatedSprite2D script)
```

### Export Variables Pattern
Heavily used for level design flexibility:
```gdscript
@export var debug_start_marker: Marker2D  # Level start override
@export var jump_multiplier: float = 1.0
@export var midair_jumps: int = 0  # grown_up_chonki only
@export var initial_camera_zoom: Vector2 = Vector2(0.2, 0.2)
```

## Testing & Development Workflow

### Running Tests
Uses **GUT** (Godot Unit Test) framework:
- Tests in `tests/` directory
- Run via: `godot --headless -s addons/gut/gut_cmdln.gd`
- Or open scene: `res://addons/gut/GutRunner.tscn`
- **Pre-push hook** (`hooks/pre-push`) auto-runs tests before git push
- Install hooks: `./install-hooks.sh`

### Test Structure
```gdscript
extends GutTest

var scene = preload("res://scenes/some_scene.gd")
var instance: Node

func before_each():
    instance = Node.new()
    instance.set_script(scene)
    add_child_autofree(instance)
    instance._ready()

func test_something():
    assert_eq(instance.property, expected_value)
```

### Debugging Scene Transitions
1. Check `SceneStack._stack.size()` to verify cache
2. Verify `process_mode` changes (disabled → inherit)
3. Ensure `scene_transition_controller.gd` only attached to `intro.tscn` (NOT an autoload)
4. Audio re-registration happens silently - no console output expected

## Code Style & Conventions

### No Comments Rule
**Do not add comments to code** - the codebase omits them intentionally.

### Null Checks
Avoid unnecessary null checks. Assume nodes/resources exist if present in scene tree unless conditionally created.

### Modern GDScript
- Use `@export` not `export var`
- Use typed variables: `var velocity: Vector2 = Vector2.ZERO`
- Prefer lambdas: `GlobalSignals.connect("win_game", func(zoom): is_game_win = true)`

### Scene Paths
Always use `res://` paths:
```gdscript
"res://scenes/level1.tscn"
"res://scripts/SceneStack.gd"
```

## Collectibles & Scoring

### Star Collection ("books" are called "stars" in code)
- Collectibles with `collectible_name = "star"` auto-join `CollectibleStar` group
- `GameState.stars_collected` tracks current level count
- `GameState.stars_per_level` caches totals by scene path
- Initialize at level start:
```gdscript
var total_stars = get_tree().get_nodes_in_group("CollectibleStar").size()
GameState.set_total_stars_for_level(level_path, total_stars)
```

### Ranking System (per level)
Thresholds in `GameState.TIME_THRESHOLDS_PER_LEVEL` by scene path:
- **Perfect**: 100% stars + time < 60s (default)
- **Great**: 50% stars + time < 80s
- **Okay**: Survive + time < 90s

### Collectible Pattern
Extends Node2D with:
- `@export var collectible_name: String` (e.g., "star", "hint")
- Floating tween animation (`float_intensity`, `float_duration`)
- Audio on collection (`@export var audio: AudioStream`)
- Hints don't increment star count (checked via `contains('hint')`)

## Health System

Lives tracked in `PlayerInventory.total_hearts` (default: 3):
- `GlobalSignals.player_hit.emit()` → `remove_heart()` → `GlobalSignals.heart_lost.emit()`
- Zero hearts → `GlobalSignals.player_out_of_hearts.emit()` → 4s "sleep" animation → level restart
- Reset on scene load: `PlayerInventory.reset_hearts()`

## Common Gotchas

1. **Signals**: Never create new signals in scripts - add to `GlobalSignals.gd`
2. **Component communication**: Use `GlobalSignals` instead of traversing scene tree with `get_node()` or `find_child()`
3. **Physics values**: Never hardcode - use `PhysicsConstants.*`
4. **Scene restoration**: Remember `_ready()` doesn't fire when popping scenes
5. **Node names**: Player body MUST be named `ChonkiCharacter` for collision detection
6. **Collectible groups**: Stars auto-group, but verify with `get_nodes_in_group("CollectibleStar")`

## Key Files Reference

- `scenes/chonki.gd` - Main player controller (puppy version)
- `scenes/grown_up_chonki.gd` - Adult corgi with midair jumps
- `scripts/SceneStack.gd` - Scene caching implementation
- `scripts/scene_transition_controller.gd` - Fade transitions (intro.tscn only)
- `scenes/Collectible.gd` - Base collectible pattern
- `scenes/GlobalSignals.gd` - All project signals
- `tests/test_kayak_float.gd` - Example GUT test structure
