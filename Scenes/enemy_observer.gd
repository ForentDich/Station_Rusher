extends Enemy

@onready var hitFlashAnimationPlayer = $HitFlashAnimationPlayer
@onready var healthComponent = $HealthComponent

	

func _child_ready():
	healthComponent.hit.connect(_on_hit_flash)
	navigationAgent = get_node("Navigation/NavigationAgent2D")

func _child_physics_process(delta):
	if navigationAgent.is_navigation_finished():
		return
		
	var axis = to_local(navigationAgent.get_next_path_position()).normalized()
	velocity = axis * move_speed
		
	move_and_slide()

func _on_hit_flash():
	hitFlashAnimationPlayer.play("hit_flash")
