extends PanelContainer

# tells desktop_manager which choice the player made
signal choice_made(outcome_data: Dictionary)

@onready var title_label: Label = $VBox/TitleLabel
@onready var content_body: RichTextLabel = $VBox/ContentBody
@onready var inspect_label: Label = $VBox/InspectDetailsLabel
@onready var option_1_btn: Button = $VBox/ChoiceHBox/Option1Btn
@onready var option_2_btn: Button = $VBox/ChoiceHBox/Option2Btn

var scenario_data: Dictionary = {}

func _ready() -> void:
	option_1_btn.pressed.connect(_on_option_1_pressed)
	option_2_btn.pressed.connect(_on_option_2_pressed)

# called by desktop_manager right after instancing this popup
func setup_popup(data: Dictionary) -> void:
	scenario_data = data
	title_label.text = data["ambient"]["speaker"]
	content_body.text = data["ambient"]["speech_bubble"]

	var choices: Array = data["choices"]
	option_1_btn.text = choices[0]["text"]
	option_2_btn.text = choices[1]["text"]

	inspect_label.text = _format_suriin_text(data["suriin"])
	inspect_label.visible = false

func _on_option_1_pressed() -> void:
	_resolve_choice(scenario_data["choices"][0])

func _on_option_2_pressed() -> void:
	_resolve_choice(scenario_data["choices"][1])

func _resolve_choice(choice: Dictionary) -> void:
	var outcome: Dictionary = choice["outcome"]
	# push the round's reward/penalty straight into the economy
	GlobalData.add_barya(outcome["barya"])
	GlobalData.update_time(outcome["time"])
	choice_made.emit(outcome)
	queue_free()

# called by desktop_manager when the Suriin tool is toggled
func set_inspecting(active: bool) -> void:
	inspect_label.visible = active

# builds readable inspect text out of summary + highlight + clues
func _format_suriin_text(suriin_data: Dictionary) -> String:
	var text: String = suriin_data["summary"] + "\n\nHighlight: " + suriin_data["highlight"]
	for clue in suriin_data["clues"]:
		text += "\n\n[%s] %s\n%s" % [clue["label"], clue["value"], clue["note"]]
	return text
