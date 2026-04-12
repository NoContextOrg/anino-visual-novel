extends CanvasLayer
## TransitionFader
##
## A full-screen black overlay used to hide scene and background swaps.
## Drop this scene anywhere in the tree; it sizes itself to the viewport
## automatically (including on resize) and renders on top of all other
## content (layer 128).

@onready var _rect: ColorRect = $ColorRect


func _ready() -> void:
	_resize_to_viewport()
	get_tree().root.size_changed.connect(_resize_to_viewport)


func _resize_to_viewport() -> void:
	_rect.size = get_viewport().get_visible_rect().size
