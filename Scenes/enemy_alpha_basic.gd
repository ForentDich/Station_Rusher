extends Enemy

@export var bullet : PackedScene = null
@export var fire_rate = 1.0
@export var bullet_speed : float = 200
@export var bullet_damage : int = 1

var can_shoot : bool = true

@onready var weaponSprite : Sprite2D = get_node("Sprite/Weapon")
@onready var endOfBarrel : Marker2D = get_node("Sprite/Weapon/EndOfBarrel")
@onready var mainSprite : Sprite2D = get_node("Sprite")
@onready var rayCast2D : RayCast2D = get_node("RayCast2D")
@onready var healthComponent = $HealthComponent
@onready var hitFlashAnimationPlayer = $HitFlashAnimationPlayer
@onready var audioStream : AudioStreamPlayer2D = $AudioStreamPlayer2D

func _child_ready():
	healthComponent.hit.connect(_on_hit_flash)
	navigationAgent = get_node("Navigation/NavigationAgent2D")



func _child_physics_process(delta):
	if target_node != null:
		rotate_to_target(target_node, delta)

	var axis = to_local(navigationAgent.get_next_path_position()).normalized()
	velocity = axis * move_speed
		
	move_and_slide()


func rotate_to_target(target, delta):
	var angle_to_target: float = global_position.direction_to(target.global_position + Vector2(0,20)).angle()
	rayCast2D.global_rotation = angle_to_target
	
	if rayCast2D.is_colliding():
		if mainSprite.scale.x > 0: weaponSprite.rotation = angle_to_target
		else: weaponSprite.rotation = -angle_to_target + PI
		gun_shoot()
	
	
	'''
	var direction = (target.global_position + Vector2(0, -24) - weaponSprite.global_position)
	var angle_to = weaponSprite.transform.x.angle_to(direction)
	weaponSprite.rotate(fmod(delta * rotation_speed * angle_to, PI))
	'''	

func gun_shoot():
	if !can_shoot:
		return
		
	if !bullet:
		return
	
	can_shoot = false
	var new_bullet : Node2D = bullet.instantiate()
	new_bullet.position = endOfBarrel.global_position
	new_bullet.bullet_speed = bullet_speed
	new_bullet.bullet_damage = bullet_damage
	new_bullet.rotation = weaponSprite.global_rotation
	get_tree().root.call_deferred("add_child", new_bullet)
	
	audioStream.play()
	await get_tree().create_timer(fire_rate).timeout
	can_shoot = true

func _on_hit_flash():
	hitFlashAnimationPlayer.play("hit_flash")
