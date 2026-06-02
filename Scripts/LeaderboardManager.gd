extends Node

signal leaderboard_updated(data)

# Mock data
var mock_leaderboard = [
	{"name": "AstroKing", "score": 50000, "level": 45},
	{"name": "SpaceExplorer", "score": 45000, "level": 42},
	{"name": "GalaxyMaster", "score": 40000, "level": 39},
	{"name": "NovaStar", "score": 35000, "level": 35},
	{"name": "MeteorSmasher", "score": 30000, "level": 30}
]

func submit_score(player_name: String, score: int, level: int):
	# Simulate network delay
	await get_tree().create_timer(1.0).timeout
	
	# Update mock data locally
	var found = false
	for entry in mock_leaderboard:
		if entry["name"] == player_name:
			entry["score"] = max(entry["score"], score)
			entry["level"] = max(entry["level"], level)
			found = true
			break
			
	if not found:
		mock_leaderboard.append({"name": player_name, "score": score, "level": level})
		
	# Sort
	mock_leaderboard.sort_custom(func(a, b): return a["score"] > b["score"])
	print("Score submitted successfully.")

func fetch_leaderboard():
	# Simulate network delay
	await get_tree().create_timer(1.0).timeout
	emit_signal("leaderboard_updated", mock_leaderboard)
