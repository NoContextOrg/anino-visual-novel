extends GutTest

const OptionsMenuScript := preload("res://src/ui/OptionsMenu.gd")


func test_main_menu_path_defined() -> void:
	assert_eq(
		OptionsMenuScript.MAIN_MENU_PATH,
		"res://scenes/ui/MainMenu.tscn",
		"MAIN_MENU_PATH should point to the main menu"
	)


func test_main_menu_scene_exists() -> void:
	assert_true(
		ResourceLoader.exists(OptionsMenuScript.MAIN_MENU_PATH),
		"Main menu scene file should exist at the expected path"
	)


func test_update_volume_label() -> void:
	var options_menu := OptionsMenuScript.new()
	# Create a mock label for the volume value
	var label := Label.new()
	options_menu.volume_value_label = label
	add_child_autoqfree(options_menu)

	options_menu._update_volume_label(75.0)
	assert_eq(label.text, "75%", "Volume label should display value with percent sign")

	options_menu._update_volume_label(0.0)
	assert_eq(label.text, "0%", "Volume label should display 0%")

	options_menu._update_volume_label(100.0)
	assert_eq(label.text, "100%", "Volume label should display 100%")
