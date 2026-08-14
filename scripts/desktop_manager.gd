extends Control

# WHAT TO SPAWN
# drag and drop popup.tscn in the empty slot in Inspector
@export var popup_scene: PackedScene

# WHERE TO SPAWN
@export var window_container: Control

# EMIT signal when player finishes scenario
signal scenario_completed(outcome_data: Dictionary)

var active_popup: PanelContainer = null

func spawn_scenario(scenario_data: Dictionary) -> void:
	if active_popup != null:
		push_warning("DesktopManager: spawn_scenario called while a popup is still active; ignoring.")
		return

	var new_popup = popup_scene.instantiate()
	window_container.add_child(new_popup)
	new_popup.setup_popup(scenario_data)
	new_popup.choice_made.connect(_on_choice_made)
	active_popup = new_popup

func _on_choice_made(outcome_data: Dictionary) -> void:
	active_popup = null
	scenario_completed.emit(outcome_data)
