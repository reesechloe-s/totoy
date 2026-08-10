# res://scripts/gacha_manager.gd
extends Control

# Signal emitted to notify UI to show the reveal animation
signal card_pulled(card_data)

const PACK_COST: int = 20

# List of 6 MVP cards with rarity weights
# Common: 50% combined, Rare: 35% combined, Super Rare: 12%, SSR: 3%
var card_pool: Array = [
	{"id": "piattos", "name": "Piattos Cheese", "rarity": "Common", "weight": 25},
	{"id": "chippy", "name": "Chippy Red", "rarity": "Common", "weight": 25},
	{"id": "mountain_dew", "name": "Mountain Dew", "rarity": "Rare", "weight": 18},
	{"id": "ice_candy", "name": "Ice Candy", "rarity": "Rare", "weight": 17},
	{"id": "piso_string", "name": "Piso with String", "rarity": "Super Rare", "weight": 12},
	{"id": "a4tech_mouse", "name": "A4Tech Ball Mouse", "rarity": "SSR", "weight": 3}
]

func buy_pack() -> bool:
	# Check if player has enough money
	if GlobalData.barya_coins < PACK_COST:
		print("Not enough Barya! Need 20 Barya.")
		return false
		
	# Deduct currency
	GlobalData.barya_coins -= PACK_COST
	
	# Roll random card
	var pulled_card: Dictionary = _roll_random_card()
	
	# Save to global collection
	if not GlobalData.unlocked_cards.has(pulled_card["id"]):
		GlobalData.unlocked_cards.append(pulled_card["id"])
		
	print("Pulled Card: ", pulled_card["name"], " (", pulled_card["rarity"], ")")
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
