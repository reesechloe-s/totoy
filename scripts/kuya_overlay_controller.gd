extends Control

# tells main_game_manager the player is ready for the next scenario
signal continue_pressed

@onready var header_label: Label = $DialogBubble/HeaderLabel
@onready var mil_tip_text: RichTextLabel = $DialogBubble/MILTipText
@onready var continue_button: Button = $DialogBubble/ContinueButton

func _ready() -> void:
	continue_button.pressed.connect(_on_continue_pressed)
	visible = false

# called by main_game_manager after a scenario's outcome is known
func show_feedback(outcome_data: Dictionary) -> void:
	header_label.text = outcome_data.get("kuya_title", "Totoy!")
	mil_tip_text.text = outcome_data.get("kuya_tip", "")
	visible = true

func _on_continue_pressed() -> void:
	visible = false
	continue_pressed.emit()
