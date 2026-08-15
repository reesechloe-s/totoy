extends Node2D

# -------------------------------------------------------------------------
# SCENE PRELOADS
# -------------------------------------------------------------------------
@export var desktop_scene: PackedScene = preload("res://scenes/ui/desktop.tscn")
@export var gacha_scene: PackedScene = preload("res://scenes/ui/gacha_screen.tscn")

# -------------------------------------------------------------------------
# NODE REFERENCES
# -------------------------------------------------------------------------
# Core UI
@onready var ui_layer: CanvasLayer = $UILayer
@onready var timer_label: Label = $UILayer/PisoTimerLabel
@onready var barya_label: Label = $UILayer/BaryaCountLabel
@onready var desktop_container: Control = $UILayer/DesktopInstance

# Intro Transition
@onready var transition_player: AnimationPlayer = $TransitionLayer/AnimationPlayer

# Overlays & Menus
@onready var kuya_overlay: Control = $OverlayLayer/KuyaOverlayInstance
@onready var level_end_screen: TextureRect = $OverlayLayer/LevelEndScreen

# Artist-Designed Texture Buttons
@onready var buy_cards_button: TextureButton = $OverlayLayer/LevelEndScreen/BuyCardsButton
@onready var store_coins_button: TextureButton = $OverlayLayer/LevelEndScreen/StoreCoinsButton

# Characters & Audio
@onready var totoy_sprite: Sprite2D = $TotoySprite
@onready var shop_audio: AudioStreamPlayer = $ShopAudioPlayer

# Peer Pressure Kids
@onready var kid_left: Sprite2D = $PeerKidsLayer/KidLeft
@onready var kid_right: Sprite2D = $PeerKidsLayer/KidRight
@onready var left_speech: Label = $PeerKidsLayer/KidLeft/SpeechBubble/Dialogue
@onready var right_speech: Label = $PeerKidsLayer/KidRight/SpeechBubble/Dialogue

# -------------------------------------------------------------------------
# STATE VARIABLES
# -------------------------------------------------------------------------
var is_game_active: bool = true
var is_timer_paused: bool = false
var level_scenarios: Array = []
var current_scenario_index: int = 0

var active_gacha_screen: Node = null
var desktop_instance: Node = null # Holds the dynamically spawned desktop

# -------------------------------------------------------------------------
# LIFECYCLE
# -------------------------------------------------------------------------
func _ready() -> void:
	# Connect Global Economy Signals
	GlobalData.barya_changed.connect(_on_barya_changed)
	GlobalData.time_changed.connect(_on_time_changed)
	update_ui()

	# The comshop background is visible immediately; the monitor UI reveals after the fade-in
	if ui_layer: ui_layer.visible = false
	if level_end_screen: level_end_screen.visible = false
	if left_speech: left_speech.visible = false
	if right_speech: right_speech.visible = false

	# 1. Instantiate the Desktop dynamically
	_instantiate_desktop()

	# Connect static overlay signals
	if kuya_overlay and kuya_overlay.has_signal("continue_pressed"):
		kuya_overlay.continue_pressed.connect(_on_kuya_continue)

	# Connect artist-designed buttons
	if buy_cards_button:
		buy_cards_button.pressed.connect(_on_buy_cards_pressed)
	if store_coins_button:
		store_coins_button.pressed.connect(_on_store_coins_pressed)

	# Fetch scenarios for the current level
	var active_level: int = GlobalData.current_level_id
	level_scenarios = JsonLoader.get_level_scenarios(active_level)

	_play_intro_transition()


func _instantiate_desktop() -> void:
	if desktop_scene and desktop_container:
		# Spawn the desktop and add it to the container
		desktop_instance = desktop_scene.instantiate()
		desktop_container.add_child(desktop_instance)
		
		# Connect the signal from the new instance
		if desktop_instance.has_signal("scenario_completed"):
			desktop_instance.scenario_completed.connect(_on_scenario_completed)


func _play_intro_transition() -> void:
	is_timer_paused = true

	if transition_player and transition_player.has_animation("fade_to_monitor"):
		transition_player.play("fade_to_monitor")
		await transition_player.animation_finished

	if ui_layer: ui_layer.visible = true
	is_timer_paused = false

	_spawn_next_scenario()

# Called every frame.
func _process(delta: float) -> void:
	if not is_game_active or is_timer_paused:
		return

	if GlobalData.piso_timer > 0:
		GlobalData.update_time(-delta)
	else:
		trigger_game_over()

# -------------------------------------------------------------------------
# UI & ECONOMY UPDATES
# -------------------------------------------------------------------------
func _on_barya_changed(new_amount: int) -> void:
	if barya_label:
		barya_label.text = str(new_amount)
	if buy_cards_button and level_end_screen and level_end_screen.visible:
		buy_cards_button.disabled = new_amount < 20


func _on_time_changed(_new_time: float) -> void:
	update_timer_display()


func update_timer_display() -> void:
	if timer_label == null:
		return
	var total_seconds: int = int(GlobalData.piso_timer)
	@warning_ignore("integer_division")
	var minutes: int = total_seconds / 60
	var seconds: int = total_seconds % 60
	timer_label.text = "%02d:%02d" % [minutes, seconds]


func update_ui() -> void:
	update_timer_display()
	if barya_label:
		barya_label.text = str(GlobalData.barya_coins)

# -------------------------------------------------------------------------
# GAMEPLAY LOOP
# -------------------------------------------------------------------------
func _spawn_next_scenario() -> void:
	if current_scenario_index >= level_scenarios.size():
		trigger_level_complete()
		return

	var current_scenario = level_scenarios[current_scenario_index]

	# Call spawn_scenario on the dynamically instanced desktop
	if desktop_instance and desktop_instance.has_method("spawn_scenario"):
		desktop_instance.spawn_scenario(current_scenario)
		
	_play_peer_pressure(current_scenario)


func _on_scenario_completed(outcome_data: Dictionary) -> void:
	current_scenario_index += 1
	is_timer_paused = true
	
	if left_speech: left_speech.visible = false
	if right_speech: right_speech.visible = false
	
	_apply_totoy_reaction(outcome_data)

	if kuya_overlay and kuya_overlay.has_method("show_feedback"):
		kuya_overlay.show_feedback(outcome_data)
	

func _on_kuya_continue() -> void:
	is_timer_paused = false
	
	var idle_path: String = "res://assets/art/characters/totoy_idle.png"
	if ResourceLoader.exists(idle_path) and totoy_sprite:
		totoy_sprite.texture = load(idle_path)
		
	_spawn_next_scenario()

# -------------------------------------------------------------------------
# VISUALS & AUDIO
# -------------------------------------------------------------------------
func _apply_totoy_reaction(outcome_data: Dictionary) -> void:
	if not outcome_data.has("totoy_state"):
		return

	var state: String = outcome_data["totoy_state"]
	var texture_path: String = "res://assets/art/characters/totoy_%s.png" % state
	if ResourceLoader.exists(texture_path) and totoy_sprite:
		totoy_sprite.texture = load(texture_path)

	var audio_path: String = "res://audios/sfx_%s.mp3" % state
	if ResourceLoader.exists(audio_path) and shop_audio:
		shop_audio.stream = load(audio_path)
		shop_audio.play()


func _play_peer_pressure(scenario_data: Dictionary) -> void:
	if left_speech: left_speech.visible = false
	if right_speech: right_speech.visible = false
	
	if not scenario_data.has("ambient"):
		return
		
	var ambient_data: Dictionary = scenario_data["ambient"]
	var bubble_text: String = ambient_data.get("speech_bubble", "")
	var speaker: String = ambient_data.get("speaker", "")
	
	if speaker == "Kid at Unit 4":
		if left_speech:
			left_speech.text = bubble_text
			left_speech.visible = true
	elif speaker == "Kid at next PC":
		if right_speech:
			right_speech.text = bubble_text
			right_speech.visible = true

# -------------------------------------------------------------------------
# LEVEL END & TRANSITIONS
# -------------------------------------------------------------------------
func trigger_game_over() -> void:
	is_game_active = false
	print("GAME OVER: Piso Time expired!")
	get_tree().change_scene_to_file("res://scenes/core/level_select.tscn")


func trigger_level_complete() -> void:
	is_game_active = false
	
	var current_lvl: int = GlobalData.current_level_id
	GlobalData.unlock_level(current_lvl + 1)

	if level_end_screen:
		level_end_screen.visible = true
		
	if buy_cards_button:
		buy_cards_button.disabled = GlobalData.barya_coins < 20


func _on_buy_cards_pressed() -> void:
	if level_end_screen:
		level_end_screen.visible = false
		
	# Dynamically instantiate the Gacha screen and add it to the OverlayLayer
	if gacha_scene:
		active_gacha_screen = gacha_scene.instantiate()
		$OverlayLayer.add_child(active_gacha_screen)
		
		# Connect the signal from the newly spawned screen
		if active_gacha_screen.has_signal("shopping_done"):
			active_gacha_screen.shopping_done.connect(_on_shopping_done)
			

func _on_store_coins_pressed() -> void:
	if level_end_screen:
		level_end_screen.visible = false
	get_tree().change_scene_to_file("res://scenes/core/level_select.tscn")


func _on_shopping_done() -> void:
	# Clean up the dynamic instance before leaving the scene
	if active_gacha_screen:
		active_gacha_screen.queue_free() 
		
	get_tree().change_scene_to_file("res://scenes/core/level_select.tscn")
