extends TabBar

func _ready():
	var resolution = Persistence.config.get_value("Video", "resolution")
	var keys = Persistence.resolution.keys()
	%OptionResolution.selected = keys[resolution]
	
	var window_mode = Persistence.config.get_value("Video", "window_mode")
	match window_mode:
		DisplayServer.WINDOW_MODE_FULLSCREEN: %OptionWindow.selected = 0
		DisplayServer.WINDOW_MODE_WINDOWED: %OptionWindow.selected = 1

func _on_option_resolution_item_selected(index):
	var current_selected : int = index
	DisplayServer.window_set_size(Persistence.resolution[current_selected])
	Persistence.config.set_value("Video", "resolution", current_selected)
	Persistence.save_data()

func _on_option_window_item_selected(index):
	var current_selected : int = index
	match current_selected:
		0: 
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
			Persistence.config.set_value("Video", "window_mode", DisplayServer.WINDOW_MODE_FULLSCREEN)
			Persistence.config.set_value("Video", "window_flag", true)
		1: 
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED); 
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
			Persistence.config.set_value("Video", "window_mode", DisplayServer.WINDOW_MODE_WINDOWED)
			Persistence.config.set_value("Video", "window_flag", false)
	Persistence.save_data()


