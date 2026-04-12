extends Control
## MasterChapter
##
## The master "Stage" scene that drives all gameplay within a chapter.
## It owns the Background display, the CharacterContainer for sprites, a
## CanvasLayer anchor for the UI, and a TransitionFader overlay used to
## hide background swaps with a smooth black-screen fade.

@onready var _background: TextureRect = $Background
@onready var _character_container: Node2D = $CharacterContainer
@onready var _ui_anchor: CanvasLayer = $UIAnchor
@onready var _fader: ColorRect = $TransitionFader/ColorRect

## Duration in seconds for each half of the cross-fade (fade-to-black then
## fade-to-clear).
const FADE_DURATION := 0.5


## Loads a new background texture from [param path] and cross-fades to it.
##
## Loading is performed asynchronously while the screen is blacked out so
## that the player never sees a stutter.  The path must point to a valid
## image resource inside [code]assets/backgrounds/[/code], for example:
## [codeblock]
##     await chapter.change_background("res://assets/backgrounds/rooftop_sunset.png")
## [/codeblock]
##
## [code]await[/code] this function when you need to proceed only after the
## transition is complete.
func change_background(path: String) -> void:
	var fade_in := create_tween()
	fade_in.tween_property(_fader, "modulate:a", 1.0, FADE_DURATION)
	await fade_in.finished

	# Kick off a non-blocking load while the screen is already black so the
	# player never sees a stutter on the reveal frame.
	var err := ResourceLoader.load_threaded_request(path)
	if err != OK:
		push_error("MasterChapter: could not request background '%s' (error %d)" % [path, err])
	else:
		var status := ResourceLoader.load_threaded_get_status(path)
		while status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			await get_tree().process_frame
			status = ResourceLoader.load_threaded_get_status(path)

		if status == ResourceLoader.THREAD_LOAD_LOADED:
			var texture: Texture2D = ResourceLoader.load_threaded_get(path)
			_background.texture = texture
		else:
			push_error("MasterChapter: failed to load background texture from '%s'" % path)

	# Always fade out so the player is never left on a permanent black screen,
	# even when loading fails.
	var fade_out := create_tween()
	fade_out.tween_property(_fader, "modulate:a", 0.0, FADE_DURATION)
	await fade_out.finished
