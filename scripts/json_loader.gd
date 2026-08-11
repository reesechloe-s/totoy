class_name JsonLoader
extends Node

<<<<<<< HEAD

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
	
=======
# dictionaries for cache
static var _scenarios_cache: Dictionary = {}
static var _gacha_cache: Dictionary = {}


# file opening logic
static func _load_json_file(file_path: String) -> Variant:
	if not FileAccess.file_exists(file_path):
		push_error("JsonLoader: File does not exist at path: " + file_path)
		return {}

	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		push_error("JsonLoader: Failed to open file at path: " + file_path)
		return {}

	var content = file.get_as_text()
	if content.strip_edges().is_empty():
		push_warning("JsonLoader: File is empty at path: " + file_path)
		return {}

	var parsed = JSON.parse_string(content)
	if parsed == null:
		push_error("JsonLoader: Failed to parse valid JSON from path: " + file_path)
		return {}

	return parsed
# LEARNING NOTES: JSON PARSE HERE READS NUMERIC VALUES, OFTEN IMPORTS THEM AS FLOAT JUST TO BE SAFE


# scenarios
static func get_all_scenarios() -> Dictionary:
	if _scenarios_cache.is_empty():
		var data = _load_json_file("res://data/scenarios.json")
		if data is Dictionary:
			_scenarios_cache = data
	return _scenarios_cache

static func get_locked_message(level_id: int) -> String:
	var scenarios_data = get_all_scenarios()
	if scenarios_data.has("levels"):
		for level_data in scenarios_data["levels"]:
			if int(level_data.get("id", -1)) == level_id:
				return level_data.get("locked_message", "")
	return ""

static func get_level_scenarios(level_id: int) -> Array:
	var level_scenarios = []
	var scenarios_data = get_all_scenarios()
	if scenarios_data.has("scenarios"):
		for scenario in scenarios_data["scenarios"]:
			if int(scenario.get("level", -1)) == level_id:
				level_scenarios.append(scenario)
	return level_scenarios


# gacha
static func get_all_gacha_cards() -> Dictionary:
	if _gacha_cache.is_empty():
		var data = _load_json_file("res://data/gacha_cards.json")
		if data is Dictionary:
			_gacha_cache = data
	return _gacha_cache
>>>>>>> 681dc9a45e64067f03518ddd119026d9f3d43522
