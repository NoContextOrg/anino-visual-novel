extends GutTest
## Tests for scenes/templates/MasterChapter.tscn and its backing script.
##
## Run with GUT:
##   gutc -d res://tests/

var _scene: Control = null


func before_each() -> void:
	_scene = preload("res://scenes/templates/MasterChapter.tscn").instantiate()
	add_child_autofree(_scene)


# ---------------------------------------------------------------------------
# Node structure
# ---------------------------------------------------------------------------

func test_has_background_node() -> void:
	assert_not_null(_scene.get_node_or_null("Background"),
			"MasterChapter should have a Background node")


func test_background_is_texture_rect() -> void:
	assert_true(_scene.get_node("Background") is TextureRect,
			"Background should be a TextureRect")


func test_has_character_container() -> void:
	assert_not_null(_scene.get_node_or_null("CharacterContainer"),
			"MasterChapter should have a CharacterContainer node")


func test_character_container_is_node2d() -> void:
	assert_true(_scene.get_node("CharacterContainer") is Node2D,
			"CharacterContainer should be a Node2D")


func test_has_ui_anchor() -> void:
	assert_not_null(_scene.get_node_or_null("UIAnchor"),
			"MasterChapter should have a UIAnchor node")


func test_ui_anchor_is_canvas_layer() -> void:
	assert_true(_scene.get_node("UIAnchor") is CanvasLayer,
			"UIAnchor should be a CanvasLayer")


func test_has_transition_fader() -> void:
	assert_not_null(_scene.get_node_or_null("TransitionFader"),
			"MasterChapter should have a TransitionFader node")


func test_transition_fader_is_canvas_layer() -> void:
	assert_true(_scene.get_node("TransitionFader") is CanvasLayer,
			"TransitionFader should be a CanvasLayer")


func test_transition_fader_has_color_rect() -> void:
	assert_not_null(_scene.get_node_or_null("TransitionFader/ColorRect"),
			"TransitionFader should contain a ColorRect child")


# ---------------------------------------------------------------------------
# Initial state
# ---------------------------------------------------------------------------

func test_fader_starts_transparent() -> void:
	var fader: ColorRect = _scene.get_node("TransitionFader/ColorRect")
	assert_eq(fader.modulate.a, 0.0,
			"TransitionFader ColorRect should start fully transparent")


func test_fader_color_is_black() -> void:
	var fader: ColorRect = _scene.get_node("TransitionFader/ColorRect")
	assert_eq(fader.color, Color(0.0, 0.0, 0.0, 1.0),
			"TransitionFader ColorRect color should be opaque black")


func test_background_has_no_initial_texture() -> void:
	var bg: TextureRect = _scene.get_node("Background")
	assert_null(bg.texture, "Background should have no texture at startup")
