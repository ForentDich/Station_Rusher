extends Node2D

func _ready():
	var rotated_list = [1, 2, 3, 4, 5].slice(2) + [1, 2, 3, 4, 5].slice(0, 2)
	print(rotated_list)

