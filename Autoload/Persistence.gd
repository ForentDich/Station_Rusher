extends Node

var resolution : Dictionary = {
	0: Vector2(1920,1080),
	1: Vector2(1600,900),
	2: Vector2(1366,768),
	3: Vector2(1280,720),
}

const PATH = "user://settings.cfg"
var config = ConfigFile.new()

func _ready():
	for action in InputMap.get_actions():
		if InputMap.action_get_events(action).size() != 0:
			config.set_value("Controls",action,InputMap.action_get_events(action)[0])
 
	config.set_value("Video", "resolution", 0)
	config.set_value("Video", "window_mode", DisplayServer.WINDOW_MODE_FULLSCREEN)
	config.set_value("Video", "window_flag", true)
 
	for i in range(3):
		config.set_value("Audio", str(i), 1.0)
 
	load_data()

func save_data():
	config.save(PATH)
	
func load_data():
	if config.load("user://settings.cfg") != OK:
		save_data()
		return
		
	load_control_settings()
	load_video_settings()


func load_control_settings():
	var keys = config.get_section_keys("Controls")
 
	for action in InputMap.get_actions():
		if keys.has(action):
			var value = config.get_value("Controls", action)
 
			InputMap.action_erase_events(action)
			InputMap.action_add_event(action, value)


func load_video_settings():
	var resolution_index = config.get_value("Video", "resolution")
	DisplayServer.window_set_size(resolution[resolution_index])
 
	var window_mode = config.get_value("Video","window_mode")
	DisplayServer.window_set_mode(window_mode)
	
	var window_flag = config.get_value("Video","window_flag")
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, window_flag)
