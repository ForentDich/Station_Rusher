extends Node

const SAVE_PATH0 : String = "user://savegame0.bin"
const SAVE_PATH1 : String = "user://savegame1.bin"
const SAVE_PATH2 : String = "user://savegame2.bin"

var current_slot : int

func save_game(slot) -> void:
	var file
	match slot:
		0: file = FileAccess.open(SAVE_PATH0, FileAccess.WRITE)
		1: file = FileAccess.open(SAVE_PATH1, FileAccess.WRITE)
		2: file = FileAccess.open(SAVE_PATH2, FileAccess.WRITE)
	
	var data: Dictionary = {
		"robots_destroyed" : StatData.robots_destroyed,
		"rooms_cleared" : StatData.rooms_cleared,
		"total_time" : StatData.total_time,
		"player_deaths" : StatData.player_deaths,
		"level_completed" : StatData.level_completed
	}
	
	var jstr = JSON.stringify(data)
	file.store_line(jstr)

func load_game(slot) -> void:
	var file
	current_slot = slot
	match slot:
		0: file = FileAccess.open(SAVE_PATH0, FileAccess.READ)
		1: file = FileAccess.open(SAVE_PATH1, FileAccess.READ)
		2: file = FileAccess.open(SAVE_PATH2, FileAccess.READ)
		
	if not file:
		reset_game(slot)
		return
	if file == null:
		return
	if not file.eof_reached():
		var current_line = JSON.parse_string(file.get_line())
		if current_line:
			StatData.robots_destroyed = current_line["robots_destroyed"]
			StatData.rooms_cleared = current_line["rooms_cleared"]
			StatData.total_time = current_line["total_time"]
			StatData.player_deaths = current_line["player_deaths"]
			StatData.level_completed = current_line["level_completed"]

func reset_game(slot) -> void:
	var file
	match slot:
		0: file = FileAccess.open(SAVE_PATH0, FileAccess.WRITE)
		1: file = FileAccess.open(SAVE_PATH1, FileAccess.WRITE)
		2: file = FileAccess.open(SAVE_PATH2, FileAccess.WRITE)
	
	var data: Dictionary = {
		"robots_destroyed" : 0,
		"rooms_cleared" : 0,
		"total_time" : 0,
		"player_deaths" : 0,
		"level_completed" : 0
	}
	
	var jstr = JSON.stringify(data)
	file.store_line(jstr)
