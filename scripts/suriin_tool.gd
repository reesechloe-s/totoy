extends TextureButton

# tells desktop_manager whether inspect mode is on or off
signal suriin_toggled(is_active: bool)

var current_data: Dictionary = {}

func _ready() -> void:
	# requires Toggle Mode checked on this node (Inspector > BaseButton)
	toggled.connect(_on_toggled)
	disabled = true # nothing to inspect until a scenario loads suriin data

func _on_toggled(toggled_on: bool) -> void:
	suriin_toggled.emit(toggled_on)

# called by desktop_manager when a scenario with suriin data spawns
func load_data(suriin_data: Dictionary) -> void:
	current_data = suriin_data
	disabled = current_data.is_empty()

# called by desktop_manager whenever a new popup spawns
func reset() -> void:
	current_data = {}
	button_pressed = false
	disabled = true
