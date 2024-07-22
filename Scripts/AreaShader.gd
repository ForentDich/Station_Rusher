extends Node2D

@export var duration : float = 1
@export var wall_shaderPathID : String
@export_range(-1.0, 1.0, 0.005) var wall_startValue : float
@export_range(-1.0, 1.0, 0.005) var wall_endValue : float
@onready var wall_curValue = 0.0
@onready var wall_needShaderMaterial : ShaderMaterial
@onready var tween

signal playerentered
signal playerexited

func _ready():
	wall_needShaderMaterial = load("res://ship.tscn::ShaderMaterial_"+wall_shaderPathID)

func _process(delta):
	wall_curValue = wall_needShaderMaterial.get_shader_parameter("DisappearHeight")

func wall_set_shader_value(value: float):
	wall_needShaderMaterial.set_shader_parameter("DisappearHeight",value)

func _on_body_entered(body):
	if body.name == "Player":
		emit_signal("playerentered")
		tween = get_tree().create_tween()
		tween.tween_method(wall_set_shader_value, wall_startValue, wall_endValue, duration)
			
func _on_body_exited(body):
	if body.name == "Player":
		emit_signal("playerexited")
		tween = get_tree().create_tween()
		tween.tween_method(wall_set_shader_value, wall_curValue, wall_startValue, duration)
