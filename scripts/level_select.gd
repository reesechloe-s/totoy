# res://scripts/level_select.gd

extends Node2D


# drag the container that should hold the level buttons here (VBoxContainer, etc.)
@export var level_button_container: Control

# optional: drag a Label here to show a locked level's warning message
@export var locked_message_label: Label

func _ready() -> void:
	_populate_level_buttons()
	if back_button:
		back_button.pressed.connect(_on_back_pressed)

# builds one button per level in scenarios.json, dimming the locked ones
func _populate_level_buttons() -> void:
	for level_data in JsonLoader.get_all_scenarios()["levels"]:
		var button := Button.new()
		button.text = level_data["display_name"]
		if not GlobalData.is_level_unlocked(level_data["id"]):
			button.modulate = Color(0.5, 0.5, 0.5)
		button.pressed.connect(_on_level_button_pressed.bind(level_data))
		level_button_container.add_child(button)

func _on_level_button_pressed(level_data: Dictionary) -> void:
	var level_id: int = level_data["id"]
	if GlobalData.is_level_unlocked(level_id):
		GlobalData.current_level_id = level_id
		GlobalData.piso_timer = float(level_data["piso_time"])
		get_tree().change_scene_to_file("res://scenes/core/main_game.tscn")
	elif locked_message_label:
		locked_message_label.text = level_data["locked_message"]
