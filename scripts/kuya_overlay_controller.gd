extends Control

# tells main_game_manager the player is ready for the next scenario
signal continue_pressed

@onready var header_label: Label = $DialogPanel/HeaderLabel
@onready var mil_tip_text: RichTextLabel = $DialogPanel/MILTipText
@onready var continue_button: Button = $DialogPanel/ContinueButton

func _ready() -> void:
	continue_button.pressed.connect(_on_continue_pressed)
	visible = false

# called by main_game_manager after a scenario's outcome is known
func show_feedback(outcome_data: Dictionary) -> void:
	header_label.text = outcome_data["kuya_title"]
	mil_tip_text.text = outcome_data["kuya_tip"]
	visible = true

func _on_continue_pressed() -> void:
	visible = false
	continue_pressed.emit()
