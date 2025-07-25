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


## Coding Conventions

- Don't add comments

- All signals live in `GlobalSignals.gd`

- Use null checks only when required. Always assume that any node or resource exists if it is present in the scene tree or code, unless you know that it is created conditionally.

- **Use the modern signal connection syntax.** When connecting signals, prefer the modern callable syntax: GlobalSignals.connect("some_signal", _on_some_signal)
