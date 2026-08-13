extends Node

signal barya_changed(new_amount)
signal time_changed(new_time)

var unlocked_levels: Dictionary = {}

# connector for level_select and main_game
var current_level_id: int = 1
var barya_coins: int = 0
var piso_timer: float = 300.0 # 5 minutes (in seconds)[cite: 1]
var unlocked_cards: Array[String] = []

# Called when the node enters the scene tree for the first time.
# check id and unlocked status
func _ready() -> void:
	# Ensure that the JsonLoader (an autoload) is placed above global data since it first needs to boot up before calling
	var all_data = JsonLoader.get_all_scenarios()
	if all_data.is_empty() or not all_data.has("levels"):
		push_error("GlobalData: failed to load scenario data; level unlock state will be empty.")
		return
	for level_data in all_data["levels"]:
		var level_id = level_data["id"]
		var is_unlocked = level_data["unlocked"]
		unlocked_levels[level_id] = is_unlocked

# we will only add barya, not subtract it. subtracting is only applicable to time
func add_barya(amount: int) -> void:
	if amount < 0:
		push_warning("GlobalData: add barya called with negative amount")
		return
	barya_coins += amount
	barya_changed.emit(barya_coins)

# spending at gacha
func spend_barya(amount: int) -> bool:
	if amount < 0:
		push_warning("GlobalData: spend_barya called with negative amount")
		return false
	if barya_coins >= amount:
		barya_coins -= amount
		barya_changed.emit(barya_coins)
		return true # successful purchase
	return false

func update_time(amount: float) -> void:
	piso_timer += amount
	if piso_timer < 0.0:
		piso_timer = 0.0
	time_changed.emit(piso_timer)

# level progression
## to be called in level selection menu
func is_level_unlocked(level_id: int) -> bool:
	return unlocked_levels.get(level_id, false)

## when totoy beats a level, the next level shall be unlocked
func unlock_level(level_id: int) -> void:
	unlocked_levels[level_id] = true

# gacha_cards inventory for album.tscn
func has_card(card_id: String) -> bool:
	return unlocked_cards.has(card_id)

func unlock_card(card_id: String) -> void:
	if not unlocked_cards.has(card_id):
		unlocked_cards.append(card_id)
