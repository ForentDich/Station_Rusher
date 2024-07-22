extends StaticBody2D

@onready var interactionArea = $InteractionArea
@onready var animationPlayer = $AnimationPlayer
@onready var audioStream = $AudioStreamPlayer2D

func _ready():
	interactionArea.interact = Callable(self, "love")
	animationPlayer.play("Idle")

func love():
	animationPlayer.play("Love")
	audioStream.play()
	await animationPlayer.animation_finished
	animationPlayer.play("Idle")
	
