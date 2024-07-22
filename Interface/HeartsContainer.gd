extends HBoxContainer
class_name HeartsContainer

@onready var heartGui = preload("res://Interface/heart.tscn")


func set_max_hearts(max: int):
	for i in range(max / 2):
		var heart = heartGui.instantiate()
		add_child(heart)
		

func update_hearts(current_health: int):
	var hearts = get_children()
	for i in hearts.size():
		if i * 2 < current_health - 1:
			hearts[i].update(0)
		elif i * 2 == current_health - 1:
			hearts[i].update(1)
		else:
			hearts[i].update(2)
