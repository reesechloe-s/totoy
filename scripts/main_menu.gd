# res://scripts/main_menu.gd
# This script handles starting the game and moving to the 
# Level Select screen:  
extends Control

# Adjust node paths based on main_menu.tscn greybox layout
@onready var start_button: Button = $StartButton

func _ready() -> void:
	# Connect button press signal
	if start_button:	
		start_button.pressed.connect(_on_start_button_pressed)

func _on_start_button_pressed() -> void:
	# Navigate to Level Select screen
	get_tree().change_scene_to_file("res://scenes/core/level_select.tscn")
