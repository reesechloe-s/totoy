# res://scripts/gacha_manager.gd
class_name GachaManager
extends Control

# Signal emitted to notify UI to show the reveal animation
signal card_pulled(card_data)
# Signal emitted when the player is done browsing the store (Option B routing)
signal shopping_done

const PACK_COST: int = 20

@onready var blind_pack_button: TextureButton = $BlindPackButton
@onready var card_display_panel: Panel = $CardDisplayPanel
@onready var card_image: TextureRect = $CardDisplayPanel/CardImage
@onready var close_button: Button = $CloseButton
@onready var done_button: Button = get_node_or_null("DoneButton")

# Loaded from res://data/gacha_cards.json (schema: {"cards": [{id, name, rarity, weight, ...}]})
var card_pool: Array = []

func _ready() -> void:
	card_pool = JsonLoader.get_all_gacha_cards().get("cards", [])
	blind_pack_button.pressed.connect(_on_blind_pack_pressed)
	close_button.pressed.connect(_on_close_pressed)
	card_display_panel.visible = false
	if done_button:
		done_button.pressed.connect(_on_done_pressed)

func _on_blind_pack_pressed() -> void:
	buy_pack()

func buy_pack() -> bool:
	if not GlobalData.spend_barya(PACK_COST):
		print("Not enough Barya! Need 20 Barya.")
		return false

	var pulled_card: Dictionary = _roll_random_card()
	GlobalData.unlock_card(pulled_card["id"])

	# name/rarity/flavor_text are baked into the card art itself; only the image is swapped here
	if pulled_card.has("image_path"):
		card_image.texture = load(pulled_card["image_path"])
	card_display_panel.visible = true

	card_pulled.emit(pulled_card)
	return true

func _roll_random_card() -> Dictionary:
	var total_weight: int = 0
	for card in card_pool:
		total_weight += card["weight"]

	var random_value: int = randi() % total_weight
	var current_weight: int = 0

	for card in card_pool:
		current_weight += card["weight"]
		if random_value < current_weight:
			return card

	return card_pool[0] # Fallback

func _on_close_pressed() -> void:
	card_display_panel.visible = false

func _on_done_pressed() -> void:
	shopping_done.emit()
