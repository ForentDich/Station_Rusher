extends MarginContainer



func _on_button_load_pressed():
	SceneTransistor.switch_scene("res://ship.tscn")
	Utils.load_game(0)
	get_tree().paused = false

func _on_button_load_2_pressed():
	SceneTransistor.switch_scene("res://ship.tscn")
	Utils.load_game(1)
	get_tree().paused = false

func _on_button_load_3_pressed():
	SceneTransistor.switch_scene("res://ship.tscn")
	Utils.load_game(2)
	get_tree().paused = false

func _on_button_clear_pressed():
	Utils.reset_game(0)


func _on_button_clear_2_pressed():
	Utils.reset_game(1)


func _on_button_clear_3_pressed():
	Utils.reset_game(2)
