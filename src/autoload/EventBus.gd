extends Node
## Global event bus for decoupled communication between game systems.
##
## Other scripts emit or connect to these signals instead of referencing
## each other directly.

## Emitted when a new line of dialogue should be displayed.
## [param data] is a [Dictionary] with at least [code]name[/code] (speaker)
## and [code]text[/code] (dialogue line) keys.
signal dialogue_started(data: Dictionary)

## Emitted when the player has finished reading the current dialogue line.
signal dialogue_finished
