extends Node2D

@export var _TileMap: TileMap
@export var Layer: int
@export_range(0, 1, 0.01) var AlphaInside: float = 0
@export_range(0, 1, 0.01) var AlphaOutside: float = 1

func _ready():
	_TileMap.set_layer_modulate(Layer,Color(1,1,1,AlphaOutside))

func _on_area_2d_body_entered(body):
	if body.name == "Player":
		_TileMap.set_layer_modulate(Layer,Color(1,1,1,AlphaInside))

func _on_area_2d_body_exited(body):
	if body.name == "Player":
		_TileMap.set_layer_modulate(Layer,Color(1,1,1,AlphaOutside))
