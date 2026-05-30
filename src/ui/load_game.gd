extends Control

@onready var back_button = $BackButton
@onready var load_btns = [$CenterContainer/SlotList/Slot1/SlotHBox1/ButtonsHBox/LoadBtn1,
	$CenterContainer/SlotList/Slot2/SlotHBox2/ButtonsHBox/LoadBtn2,
	$CenterContainer/SlotList/Slot3/SlotHBox3/ButtonsHBox/LoadBtn3]
@onready var delete_btns = [$CenterContainer/SlotList/Slot1/SlotHBox1/ButtonsHBox/DeleteBtn1,
	$CenterContainer/SlotList/Slot2/SlotHBox2/ButtonsHBox/DeleteBtn2,
	$CenterContainer/SlotList/Slot3/SlotHBox3/ButtonsHBox/DeleteBtn3]

func _ready():
	back_button.pressed.connect(_on_back_pressed)
	for i in range(3):
		var slot_index = i
		load_btns[i].pressed.connect(func(): _on_load_pressed(slot_index))
		delete_btns[i].pressed.connect(func(): _on_delete_pressed(slot_index))

func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")

func _on_load_pressed(slot: int):
	# TODO: implement save data loading for slot
	print("Load slot: ", slot + 1)

func _on_delete_pressed(slot: int):
	# TODO: implement save data deletion for slot
	print("Delete slot: ", slot + 1)
