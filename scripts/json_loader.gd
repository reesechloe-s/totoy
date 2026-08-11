extends Node


#dictionaries for cache
var _scenarios_cache: Dictionary = {}
var _gacha_cache: Dictionary = {}


# file opening logic
func _load_json_file(file_path: String) -> Variant:
	var file = FileAccess.open(file_path, FileAccess.READ)
	var content = file.get_as_text()
	return JSON.parse_string(content)
# LEARNING NOTES: JSON PARSE HERE READS NUMERIC VALUES, OFTEN IMPORTS THEM AS FLOAT JUST TO BE SAFE

#scenarios
func get_all_scenarios() -> Dictionary:
	if _scenarios_cache.is_empty():
		_scenarios_cache = _load_json_file("res://data/scenarios.json")
	return _scenarios_cache

func get_locked_message(level_id: int) -> String:
	for level_data in get_all_scenarios()["levels"]:
		if level_data["id"] == level_id:
			return level_data["locked_message"]
	return ""

func get_level_scenarios(level_id: int) -> Array:
	var level_scenarios = []
	for scenario in get_all_scenarios()["scenarios"]:
		if scenario["level"] == level_id:
			level_scenarios.append(scenario)
	return level_scenarios

#gacha
func get_all_gacha_cards() -> Dictionary:
	if _gacha_cache.is_empty():
		_gacha_cache = _load_json_file("res://data/gacha_cards.json")
	return _gacha_cache
	
