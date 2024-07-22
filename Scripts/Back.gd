extends Button

@onready var main = %Main
@onready var settings = %Settings


func _on_pressed():
	main.show()
	settings.hide()
