extends Panel

@onready var sprite = $Sprite2D

func update(index : int):
	match index:
		0: sprite.frame = 0
		1: sprite.frame = 1
		2: sprite.frame = 2
