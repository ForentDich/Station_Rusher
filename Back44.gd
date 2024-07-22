extends Button

@onready var saves = %Saves
@onready var mainMenu = %MainMenu


func _on_pressed():
	mainMenu.show()
	saves.hide()
