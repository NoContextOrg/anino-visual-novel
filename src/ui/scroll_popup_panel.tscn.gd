class_name ScrollPopupPanel
extends Control # This changed!

@onready var info_label: Label = $scroll_popup_panel/margin_container/label

# Bring back your custom signal!
signal closed 

func display_info(text_content: String) -> void:
    info_label.text = text_content
    show() # Replaced popup_centered() with a standard show()

func _on_close_btn_pressed() -> void:
    hide()
    closed.emit() # Tell the main scene we closed!