extends PanelContainer

# tells desktop_manager which choice the player made
signal choice_made(outcome_data: Dictionary)

@onready var scenario_image_view: TextureRect = $VBox/ScenarioImageView
@onready var suriin_toggle_button: TextureButton = $VBox/ChoiceHBox/SuriinToggleButton
@onready var choice_hbox: HBoxContainer = $VBox/ChoiceHBox

@onready var suriin_popup_panel: PanelContainer = $SuriinPopupPanel
@onready var suriin_summary_label: Label = $SuriinPopupPanel/SuriinVBox/SummaryLabel
@onready var suriin_highlight_label: Label = $SuriinPopupPanel/SuriinVBox/Highlightlabel
@onready var suriin_clues_list: VBoxContainer = $SuriinPopupPanel/SuriinVBox/CluesList
@onready var suriin_close_btn: Button = $SuriinPopupPanel/SuriinVBox/CloseBtn

var scenario_data: Dictionary = {}

func _ready() -> void:
	suriin_toggle_button.pressed.connect(_on_suriin_toggle_pressed)
	suriin_close_btn.pressed.connect(_on_suriin_close_pressed)
	suriin_popup_panel.visible = false

# called by desktop_manager right after instancing this popup
func setup_popup(data: Dictionary) -> void:
	scenario_data = data

	var image_path: String = data.get("image_path", "")
	if image_path != "" and ResourceLoader.exists(image_path):
		scenario_image_view.texture = load(image_path)

	_populate_choices(data.get("choices", []))

	var suriin_data: Dictionary = data.get("suriin", {})
	suriin_toggle_button.disabled = suriin_data.is_empty()
	if not suriin_data.is_empty():
		_populate_suriin(suriin_data)

# builds one button per choice so a scenario isn't locked to exactly two options
func _populate_choices(choices: Array) -> void:
	for child in choice_hbox.get_children():
		child.queue_free()

	for choice in choices:
		var choice_button := Button.new()
		choice_button.text = choice.get("text", "")
		choice_button.pressed.connect(_resolve_choice.bind(choice))
		choice_hbox.add_child(choice_button)

func _on_suriin_toggle_pressed() -> void:
	suriin_popup_panel.visible = not suriin_popup_panel.visible

func _on_suriin_close_pressed() -> void:
	suriin_popup_panel.visible = false

func _resolve_choice(choice: Dictionary) -> void:
	var outcome: Dictionary = choice.get("outcome", {})
	# push the round's reward/penalty straight into the economy
	GlobalData.add_barya(outcome.get("barya", 0))
	GlobalData.update_time(outcome.get("time", 0.0))
	choice_made.emit(outcome)
	queue_free()

# builds the clue panel out of summary + highlight + per-clue rows
func _populate_suriin(suriin_data: Dictionary) -> void:
	suriin_summary_label.text = suriin_data.get("summary", "")

	var highlight_text: String = suriin_data.get("highlight", "")
	suriin_highlight_label.text = highlight_text
	suriin_highlight_label.visible = highlight_text != ""

	for child in suriin_clues_list.get_children():
		child.queue_free()

	for clue in suriin_data.get("clues", []):
		var clue_label := Label.new()
		clue_label.text = "[%s] %s\n%s" % [clue.get("label", ""), clue.get("value", ""), clue.get("note", "")]
		clue_label.autowrap_mode = TextServer.AUTOWRAP_WORD
		suriin_clues_list.add_child(clue_label)
