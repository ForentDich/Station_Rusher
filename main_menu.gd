extends Control

@onready var main = %Main
@onready var settings = %Settings
@onready var saves = %Saves

func _ready():
	SceneTransistor.can_show.emit()


func _on_start_button_pressed():
	Utils.load_game(0)
	SceneTransistor.switch_scene("res://ship.tscn")

func _on_save_button_pressed():
	saves.show()
	main.hide()

func _on_options_button_pressed():
	settings.show()
	main.hide()


func _on_exit_button_pressed():
	get_tree().quit()
