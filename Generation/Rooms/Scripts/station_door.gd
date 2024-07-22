extends Node2D

var is_lock : bool = false

@onready var sprite2D = $StaticBody2D/Sprite2D
@onready var animationPlayer = $AnimationPlayer
@onready var audioStream = $AudioStreamPlayer2D

func _ready():
	sprite2D.frame = 0


func lock():
	if sprite2D.frame != 0:
		animationPlayer.play_backwards("Open")
		await get_tree().create_timer(sprite2D.frame/50.0).timeout
	animationPlayer.play("Lock")
	is_lock = true
	

func unlock():
	is_lock = false
	sprite2D.frame = 0


func _on_area_2d_body_entered(body):
	if body.is_in_group("Player") and is_lock == false:
		animationPlayer.play("Open")
		audioStream.play()
		


func _on_area_2d_body_exited(body):
	if body.is_in_group("Player") and is_lock == false:
		if sprite2D.frame != 0:
			animationPlayer.play_backwards("Open")

