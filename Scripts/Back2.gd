extends Button

@onready var saves = %Saves
@onready var main = %Main

func _on_pressed():
	main.show()
	saves.hide()
	
