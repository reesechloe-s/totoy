# res://scripts/gacha_manager.gd
class_name GachaManager
extends Control

# Signal emitted to notify UI to show the reveal animation
signal card_pulled(card_data)
# Signal emitted when the player is done browsing the store (Option B routing)
signal shopping_done

const PACK_COST: int = 20

@onready var blind_pack_button: TextureButton = get_node_or_null("BlindPackButton")
@onready var card_display_panel: Panel = get_node_or_null("CardDisplayPanel")
@onready var card_image: TextureRect = get_node_or_null("CardDisplayPanel/CardImage")
@onready var close_button: Button = get_node_or_null("CloseButton")
@onready var done_button: Button = get_node_or_null("DoneButton")

# Loaded from res://data/gacha_cards.json (schema: {"cards": [{id, name, rarity, weight, ...}]})
var card_pool: Array = []


func _ready() -> void:
	var gacha_data: Dictionary = JsonLoader.get_all_gacha_cards()
	card_pool = gacha_data.get("cards", [])

	if blind_pack_button:
		blind_pack_button.pressed.connect(_on_blind_pack_pressed)

	if close_button:
		close_button.pressed.connect(_on_close_pressed)

	if card_display_panel:
		card_display_panel.visible = false

	if done_button:
		done_button.pressed.connect(_on_done_pressed)


func _on_blind_pack_pressed() -> void:
	buy_pack()


func buy_pack() -> bool:
	if card_pool.is_empty():
		push_error("GachaManager: Cannot buy pack! card_pool is empty. Check gacha_cards.json.")
		return false

	if not GlobalData.spend_barya(PACK_COST):
		print("Not enough Barya! Need 20 Barya.")
		return false

	var pulled_card: Dictionary = _roll_random_card()
	if pulled_card.is_empty():
		push_error("GachaManager: Failed to roll a valid card.")
		return false

	if pulled_card.has("id"):
		GlobalData.unlock_card(pulled_card["id"])

	# name/rarity/flavor_text are baked into the card art itself; only the image is swapped here
	if pulled_card.has("image_path") and card_image:
		var img_path: String = pulled_card["image_path"]
		if ResourceLoader.exists(img_path):
			card_image.texture = load(img_path)
		else:
			push_warning("GachaManager: Card texture path not found: " + img_path)

	if card_display_panel:
		card_display_panel.visible = true

	card_pulled.emit(pulled_card)
	return true


func _roll_random_card() -> Dictionary:
	if card_pool.is_empty():
		return {}

	var total_weight: int = 0
	for card in card_pool:
		total_weight += int(card.get("weight", 1))

	if total_weight <= 0:
		return card_pool[0]

	var random_value: int = randi() % total_weight
	var current_weight: int = 0

	for card in card_pool:
		current_weight += int(card.get("weight", 1))
		if random_value < current_weight:
			return card

	return card_pool[0] # Fallback


func _on_close_pressed() -> void:
	if card_display_panel:
		card_display_panel.visible = false


func _on_done_pressed() -> void:
	shopping_done.emit()
