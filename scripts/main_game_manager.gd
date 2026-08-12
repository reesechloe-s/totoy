extends Node2D

# Node References — match main_game.tscn's real tree
@onready var timer_label: Label = $UILayer/MonitorBezel/PisoTimerLabel
@onready var barya_label: Label = $UILayer/MonitorBezel/BaryaCountLabel
@onready var desktop: Control = $UILayer/DesktopInstance
@onready var kuya_overlay: Control = $OverlayLayer/KuyaOverlayInstance
@onready var gacha_screen: Control = $OverlayLayer/GachaScreenInstance
@onready var totoy_sprite: Sprite2D = $TotoySprite

# end-of-level choice buttons — drag them in once added to the scene
# (BaseButton so either a Button or a TextureButton can be assigned)
@export var buy_cards_button: BaseButton
@export var store_coins_button: BaseButton

var is_game_active: bool = true
var is_timer_paused: bool = false
var level_scenarios: Array = []
var current_scenario_index: int = 0


func _ready() -> void:
	GlobalData.barya_changed.connect(_on_barya_changed)
	GlobalData.time_changed.connect(_on_time_changed)
	update_ui()

	if gacha_screen:
		gacha_screen.visible = false
		if gacha_screen.has_signal("shopping_done"):
			gacha_screen.shopping_done.connect(_on_shopping_done)

	# Fetch scenarios for the current level (defaulting to level 1 if not set)
	var active_level: int = GlobalData.get("current_level_id") if "current_level_id" in GlobalData else 1
	level_scenarios = JsonLoader.get_level_scenarios(active_level)

	if desktop and desktop.has_signal("scenario_completed"):
		desktop.scenario_completed.connect(_on_scenario_completed)

	if kuya_overlay and kuya_overlay.has_signal("continue_pressed"):
		kuya_overlay.continue_pressed.connect(_on_kuya_continue)

	if buy_cards_button:
		buy_cards_button.visible = false
		buy_cards_button.pressed.connect(_on_buy_cards_pressed)

	if store_coins_button:
		store_coins_button.visible = false
		store_coins_button.pressed.connect(_on_store_coins_pressed)

	_spawn_next_scenario()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not is_game_active or is_timer_paused:
		return

	if GlobalData.piso_timer > 0:
		GlobalData.update_time(-delta)
	else:
		trigger_game_over()


func _on_barya_changed(new_amount: int) -> void:
	if barya_label:
		barya_label.text = str(new_amount)
	# keep the dimmed state live in case balance changes while the choice is up
	if buy_cards_button and buy_cards_button.visible:
		buy_cards_button.disabled = new_amount < 20


func _on_time_changed(_new_time: float) -> void:
	update_timer_display()


func update_timer_display() -> void:
	if timer_label == null:
		return
	# Convert seconds into MM:SS format
	var total_seconds: int = int(GlobalData.piso_timer)
	@warning_ignore("integer_division")
	var minutes: int = total_seconds / 60
	var seconds: int = total_seconds % 60
	timer_label.text = "%02d:%02d" % [minutes, seconds]


func update_ui() -> void:
	update_timer_display()
	if barya_label:
		barya_label.text = str(GlobalData.barya_coins)


func trigger_game_over() -> void:
	is_game_active = false
	print("GAME OVER: Piso Time expired!")
	# Return to Level Select on Game Over
	get_tree().change_scene_to_file("res://scenes/core/level_select.tscn")


func _spawn_next_scenario() -> void:
	if current_scenario_index >= level_scenarios.size():
		trigger_level_complete()
		return

	if desktop and desktop.has_method("spawn_scenario"):
		desktop.spawn_scenario(level_scenarios[current_scenario_index])


# desktop_manager calls this once a popup's choice is resolved
func _on_scenario_completed(outcome_data: Dictionary) -> void:
	current_scenario_index += 1
	is_timer_paused = true
	_apply_totoy_reaction(outcome_data)

	if kuya_overlay and kuya_overlay.has_method("show_feedback"):
		kuya_overlay.show_feedback(outcome_data)


# kuya_overlay_controller calls this once the player taps Continue
func _on_kuya_continue() -> void:
	is_timer_paused = false
	_spawn_next_scenario()


# swaps Totoy's expression once matching art exists in assets/art/totoy/
func _apply_totoy_reaction(outcome_data: Dictionary) -> void:
	if not outcome_data.has("totoy_state"):
		return

	var texture_path: String = "res://assets/art/totoy/totoy_%s.png" % outcome_data["totoy_state"]
	if ResourceLoader.exists(texture_path) and totoy_sprite:
		totoy_sprite.texture = load(texture_path)


# gacha_manager calls this once the player is done shopping
func _on_shopping_done() -> void:
	if gacha_screen:
		gacha_screen.visible = false
	get_tree().change_scene_to_file("res://scenes/core/level_select.tscn")


func trigger_level_complete() -> void:
	is_game_active = false
	
	var current_lvl: int = GlobalData.get("current_level_id") if "current_level_id" in GlobalData else 1
	GlobalData.unlock_level(current_lvl + 1)

	if buy_cards_button:
		buy_cards_button.visible = true
		buy_cards_button.disabled = GlobalData.barya_coins < 20

	if store_coins_button:
		store_coins_button.visible = true

	print("Level complete!")


# player chose to spend their Barya on a blind pack
func _on_buy_cards_pressed() -> void:
	if buy_cards_button:
		buy_cards_button.visible = false
	if store_coins_button:
		store_coins_button.visible = false
	if gacha_screen:
		gacha_screen.visible = true


# player chose to keep their Barya and skip the store
func _on_store_coins_pressed() -> void:
	if buy_cards_button:
		buy_cards_button.visible = false
	if store_coins_button:
		store_coins_button.visible = false
	get_tree().change_scene_to_file("res://scenes/core/level_select.tscn")
