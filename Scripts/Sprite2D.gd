extends Sprite2D

func _ready():
	$".".material = $".".material.duplicate()
	$".".texture = $".".texture.duplicate()

