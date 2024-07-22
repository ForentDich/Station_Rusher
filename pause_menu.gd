extends CanvasLayer

@onready var main = $"../"
@onready var mainMenu = %MainMenu
@onready var settings = %Settings
@onready var saves = %Saves

func _on_resume_pressed():
	main.pause_menu()


func _on_quit_pressed():
	match get_tree().current_scene.name:
		"Ship": SceneTransistor.switch_scene("res://main_menu.tscn")
		"World": SceneTransistor.switch_scene("res://ship.tscn")
	get_tree().paused = false


func _on_settings_pressed():
	settings.show()
	mainMenu.hide()


func _on_save_pressed():
	saves.show()
	mainMenu.hide()
