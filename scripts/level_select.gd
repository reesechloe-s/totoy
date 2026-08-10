# res://scripts/level_select.gd
extends Control

# Adjust node paths based on level_select.tscn greybox layout
@onready var level_1_button: Button = $Level1Button
@onready var level_2_button: Button = $Level2Button
@onready var back_button: Button = $BackButton

func _ready() -> void:
	if level_1_button:
		level_1_button.pressed.connect(_on_level_1_pressed)
	if level_2_button:
		level_2_button.pressed.connect(_on_level_2_pressed)
	if back_button:
		back_button.pressed.connect(_on_back_pressed)

func _on_level_1_pressed() -> void:
	# Reset timer & load game scene for Level 1
	GlobalData.piso_timer = 300.0
	get_tree().change_scene_to_file("res://scenes/core/main_game.tscn")

func _on_level_2_pressed() -> void:
	# Reset timer & load game scene for Level 2
	GlobalData.piso_timer = 300.0
	get_tree().change_scene_to_file("res://scenes/core/main_game.tscn")

func _on_back_pressed() -> void:
	# Return to Main Menu
	get_tree().change_scene_to_file("res://scenes/core/main_menu.tscn")
