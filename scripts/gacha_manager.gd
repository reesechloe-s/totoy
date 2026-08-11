# res://scripts/gacha_manager.gd
extends Control

# Signal emitted to notify UI to show the reveal animation
signal card_pulled(card_data)

const PACK_COST: int = 20

@onready var blind_pack_button: TextureButton = $BlindPackButton
@onready var card_display_panel: Panel = $CardDisplayPanel
@onready var card_title: Label = $CardDisplayPanel/CardTitle
@onready var rarity_label: Label = $CardDisplayPanel/RarityLabel
@onready var close_button: Button = $CardDisplayPanel/CloseButton


# List of 6 MVP cards with rarity weights
# Common: 50% combined, Rare: 35% combined, Super Rare: 12%, SSR: 3%
# TODO: swap this for JsonLoader.get_all_gacha_cards() once data/gacha_cards.json is filled in
var card_pool: Array = [
	{"id": "piattos", "name": "Piattos Cheese", "rarity": "Common", "weight": 25},
	{"id": "chippy", "name": "Chippy Red", "rarity": "Common", "weight": 25},
	{"id": "mountain_dew", "name": "Mountain Dew", "rarity": "Rare", "weight": 18},
	{"id": "ice_candy", "name": "Ice Candy", "rarity": "Rare", "weight": 17},
	{"id": "piso_string", "name": "Piso with String", "rarity": "Super Rare", "weight": 12},
	{"id": "a4tech_mouse", "name": "A4Tech Ball Mouse", "rarity": "SSR", "weight": 3}
]

func _ready() -> void:
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

	card_title.text = pulled_card["name"]
	rarity_label.text = pulled_card["rarity"]
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
