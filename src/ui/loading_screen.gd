extends Control

@onready var spinner: TextureRect = $SpinnerIndicator
@onready var progress_bar: ProgressBar = $ProgressBar
@onready var hint_label: Label = $HintLabel
@onready var hint_timer: Timer = $Timer

@export var spinner_speed: float = 4.0 

@export var hints: Array[String] = [
	"Gameplay Tip: Remember to save your progress frequently!",
	"Lore: The ancient artifacts were scattered during the Great Sundering.",
	"Gameplay Tip: Combining different elements yields unique effects.",
	"Lore: Legends say the map changes based on the moon's phase."
]

var _current_hint: String = ""

# --- MOCK DATA VARIABLES ---
@export_group("Testing")
@export var use_mock_data: bool = true 
var _mock_progress_value: float = 0.0

func _ready() -> void:
	hint_timer.timeout.connect(_on_hint_timer_timeout)
	update_hint()

	progress_bar.value = 0.0

func _process(delta: float) -> void:
	if spinner:
		spinner.rotation += spinner_speed * delta
		
	# --- MOCK DATA VARIABLES ---
	if use_mock_data and _mock_progress_value < 100.0:
		_mock_progress_value += randf_range(5.0, 15.0) * delta
		
		if _mock_progress_value > 100.0:
			_mock_progress_value = 100.0
			print("Mock Loading Complete!")
			
		update_progress(_mock_progress_value)

func _on_hint_timer_timeout() -> void:
	update_hint()

func update_hint() -> void:
	if hints.is_empty():
		return
		
	var next_hint: String = _current_hint
	while next_hint == _current_hint and hints.size() > 1:
		next_hint = hints.pick_random()
		
	_current_hint = next_hint
	hint_label.text = _current_hint

# Call your manager
func update_progress(value: float) -> void:
	progress_bar.value = value
