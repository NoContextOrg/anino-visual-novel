extends Control

@onready var anim_player = $UI_Anchor/AnimationPlayer
@onready var fader = $UI_Anchor/TransitionFader

func transition_to_scene(target_scene_path: String):
	
	anim_player.play("fade_out")
	
	await anim_player.animation_finished
	
	get_tree().change_scene_to_file(target_scene_path)

func _input(event):
	if event.is_action_pressed("proceed"):
		_fade()

func _fade():
	anim_player.play("fade_out")
