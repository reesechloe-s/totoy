extends Control

# WHAT TO SPAWN
# drag and drop popup.tscn in the empty slot in Inspector
@export var popup_scene: PackedScene

# WHERE TO SPAWN
@export var window_container: Control

# Grab suriin tool button so we can talk to it (SuriinTool node in desktop.tscn)
@onready var suriin_tool: TextureButton = $SuriinTool

# EMIT signal when player finishes scenario
signal scenario_completed(outcome_data: Dictionary)

var active_popup: PanelContainer = null

func _ready() -> void:
	suriin_tool.suriin_toggled.connect(_on_suriin_toggled)

func spawn_scenario(scenario_data: Dictionary) -> void:
	suriin_tool.reset()

	var new_popup = popup_scene.instantiate()
	window_container.add_child(new_popup)
	new_popup.setup_popup(scenario_data)
	new_popup.choice_made.connect(_on_choice_made)
	active_popup = new_popup

	if scenario_data.has("suriin"):
		suriin_tool.load_data(scenario_data["suriin"])

func _on_choice_made(outcome_data: Dictionary) -> void:
	active_popup = null
	scenario_completed.emit(outcome_data)

func _on_suriin_toggled(is_active: bool) -> void:
	if active_popup:
		active_popup.set_inspecting(is_active)
