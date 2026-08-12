# res://scripts/level_select.gd

extends Node2D

# drag the container that should hold the level buttons here (VBoxContainer, etc.)
@export var level_button_container: Control

# optional: drag a Label here to show a locked level's warning message
@export var locked_message_label: Label

# optional: drag a Back Button node here to return to Main Menu
@export var back_button: Button


func _ready() -> void:
	_populate_level_buttons()
	if back_button:
		back_button.pressed.connect(_on_back_pressed)


# builds one button per level in scenarios.json, dimming the locked ones
func _populate_level_buttons() -> void:
	if level_button_container == null:
		push_error("LevelSelect: level_button_container is not assigned in the Inspector!")
		return

	var scenarios_data = JsonLoader.get_all_scenarios()
	if not scenarios_data.has("levels"):
		push_error("LevelSelect: No 'levels' key found in scenarios.json")
		return

	for level_data in scenarios_data["levels"]:
		var button := Button.new()
		button.text = level_data.get("display_name", "Level " + str(level_data["id"]))
		
		var level_id: int = int(level_data["id"])
		var is_unlocked: bool = GlobalData.is_level_unlocked(level_id)
		
		if not is_unlocked:
			button.modulate = Color(0.5, 0.5, 0.5)
			
		button.pressed.connect(_on_level_button_pressed.bind(level_data))
		level_button_container.add_child(button)


func _on_level_button_pressed(level_data: Dictionary) -> void:
	var level_id: int = int(level_data["id"])
	
	if GlobalData.is_level_unlocked(level_id):
		# Reset timer to default 5 minutes (300 seconds) or custom level time
		var level_time: float = float(level_data.get("piso_time", 300.0))
		GlobalData.reset_timer(level_time)
		
		get_tree().change_scene_to_file("res://scenes/core/main_game.tscn")
	elif locked_message_label:
		locked_message_label.text = level_data.get("locked_message", "This level is locked!")


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/core/main_menu.tscn")
