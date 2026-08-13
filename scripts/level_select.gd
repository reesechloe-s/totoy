# res://scripts/level_select.gd
extends Control

@onready var level_1_button: TextureButton = $WindowPanel/MainHBox/LevelSection/LevelGrid/Level1Button
@onready var level_2_button: TextureButton = $WindowPanel/MainHBox/LevelSection/LevelGrid/Level2Button
@onready var level_3_button: TextureButton = $WindowPanel/MainHBox/LevelSection/LevelGrid/Level3Button
@onready var level_4_button: TextureButton = $WindowPanel/MainHBox/LevelSection/LevelGrid/Level4Button

func _ready() -> void:
	# Locked levels show their padlock art automatically via the Disabled texture slot.
	var level_buttons: Dictionary = {
		1: level_1_button,
		2: level_2_button,
		3: level_3_button,
		4: level_4_button,
	}

	for level_id in level_buttons:
		var button: TextureButton = level_buttons[level_id]
		button.disabled = not GlobalData.is_level_unlocked(level_id)
		button.pressed.connect(_on_level_button_pressed.bind(level_id))


func _on_level_button_pressed(level_id: int) -> void:
	GlobalData.current_level_id = level_id
	get_tree().change_scene_to_file("res://scenes/core/main_game.tscn")
