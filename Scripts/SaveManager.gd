extends Node

var save_path = "user://astro_save.json"

var current_level = 1
var high_score = 0
var total_score = 0
var player_name = "AstroPlayer"

func _ready():
	load_game()

func save_game():
	var save_dict = {
		"current_level": current_level,
		"high_score": high_score,
		"total_score": total_score,
		"player_name": player_name
	}
	
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_dict))
		file.close()

func load_game():
	if not FileAccess.file_exists(save_path):
		return
	
	var file = FileAccess.open(save_path, FileAccess.READ)
	if file:
		var content = file.get_as_text()
		var json = JSON.new()
		var error = json.parse(content)
		if error == OK:
			var data = json.get_data()
			if data.has("current_level"):
				current_level = data["current_level"]
			if data.has("high_score"):
				high_score = data["high_score"]
			if data.has("total_score"):
				total_score = data["total_score"]
			if data.has("player_name"):
				player_name = data["player_name"]
		file.close()

func level_up():
	current_level += 1
	save_game()

func add_score(points):
	total_score += points
	if total_score > high_score:
		high_score = total_score
	save_game()
