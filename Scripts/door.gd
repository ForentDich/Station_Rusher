extends Node2D

@export_group("Parameter")
@export var _texture : Texture
@export var area : NodePath
@export var duration : float = 1
@export_range(-1.0, 1.0, 0.005) var startValue : float = 0.8
@export_range(-1.0, 1.0, 0.005) var endValue : float = -0.3
var spriteShader : ShaderMaterial
var tween
var curValue = 0.0

func _ready():
	$StaticBody2D/Sprite2D.texture = _texture
	spriteShader = $StaticBody2D/Sprite2D.material
	$AnimationPlayer.play("DoorClosed")
	
	var new_area : Area2D
	new_area = get_node(area)
	
	new_area.connect("playerentered",area_body_entered)
	new_area.connect("playerexited",area_body_exited)

func _process(delta):
	curValue = spriteShader.get_shader_parameter("DisappearHeight")

func _on_area_2d_body_entered(body):
	if body.name == "Player":
		$AudioStreamPlayer2D.play()
		$AnimationPlayer.play("DoorOpened")
		

func _on_area_2d_body_exited(body):
	if body.name == "Player":
		$AnimationPlayer.play_backwards("DoorOpened")
		
func door_set_shader_value(value: float):
	spriteShader.set_shader_parameter("DisappearHeight", value)
	

func area_body_entered():
	tween = get_tree().create_tween()
	tween.tween_method(door_set_shader_value, startValue, endValue, duration)

func area_body_exited():
	tween = get_tree().create_tween()
	tween.tween_method(door_set_shader_value, curValue, startValue, duration)

