extends AnimatedSprite2D

func _ready() -> void:
	play("default")
	

func _on_animation_finished():
	queue_free()
