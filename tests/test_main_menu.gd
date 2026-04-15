extends GutTest

const MainMenuScript := preload("res://src/ui/MainMenu.gd")


func test_constants_defined() -> void:
	assert_eq(
		MainMenuScript.FIRST_CHAPTER_PATH,
		"res://scenes/templates/MasterChapter.tscn",
		"FIRST_CHAPTER_PATH should point to the chapter template"
	)
	assert_eq(
		MainMenuScript.OPTIONS_MENU_PATH,
		"res://scenes/ui/OptionsMenu.tscn",
		"OPTIONS_MENU_PATH should point to the options menu"
	)


func test_chapter_scene_exists() -> void:
	assert_true(
		ResourceLoader.exists(MainMenuScript.FIRST_CHAPTER_PATH),
		"First chapter scene file should exist at the expected path"
	)


func test_options_scene_exists() -> void:
	assert_true(
		ResourceLoader.exists(MainMenuScript.OPTIONS_MENU_PATH),
		"Options menu scene file should exist at the expected path"
	)
