extends Node

# dictionaries for cache
var _scenarios_cache: Dictionary = {}
var _gacha_cache: Dictionary = {}


# file opening logic
func _load_json_file(file_path: String) -> Variant:
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
func get_all_scenarios() -> Dictionary:
	if _scenarios_cache.is_empty():
		var data = _load_json_file("res://data/scenarios.json")
		if data is Dictionary:
			_scenarios_cache = data
	return _scenarios_cache

func get_locked_message(level_id: int) -> String:
	var scenarios_data = get_all_scenarios()
	if scenarios_data.has("levels"):
		for level_data in scenarios_data["levels"]:
			if int(level_data.get("id", -1)) == level_id:
				return level_data.get("locked_message", "")
	return ""

func get_level_scenarios(level_id: int) -> Array:
	var level_scenarios = []
	var scenarios_data = get_all_scenarios()
	if scenarios_data.has("scenarios"):
		for scenario in scenarios_data["scenarios"]:
			if int(scenario.get("level", -1)) == level_id:
				level_scenarios.append(scenario)
	return level_scenarios


# gacha
func get_all_gacha_cards() -> Dictionary:
	if _gacha_cache.is_empty():
		var data = _load_json_file("res://data/gacha_cards.json")
		if data is Dictionary:
			_gacha_cache = data
	return _gacha_cache

# LEARNING NOTES
## WHY WE DON'T NEED TO HAVE func_get_choices?
## When JsonLoader grabs a scenario like "l1_nokia_scam", it grabs the entire dictionary block for that scenario. Because the "choices" array is nested securely inside that specific scenario block, it gets pulled in automatically.
## syntax for if int(level_data.get("id", -1)) == level_id:
## "Extract the ID from this block of data. Make absolutely sure it is an integer. If the ID is missing, pretend it is -1. Now, does that ID equal 1? If yes, this is the level we are looking for!"
