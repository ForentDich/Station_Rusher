extends CharacterBody2D

@export var bullet : PackedScene = null
@export var fire_rate = 1.0
@export var bullet_speed : float = 200
@export var bullet_damage : int = 1

var bullet_number : int = 3
var counter : int = 0
var bullet_angle = deg_to_rad(25.0)
var angle_offset = deg_to_rad(0.0)

var can_shoot : bool = true

@onready var weaponSprite : Sprite2D = get_node("Sprite/Weapon")
@onready var endOfBarrel : Marker2D = get_node("Sprite/Weapon/EndOfBarrel")
@onready var mainSprite : Sprite2D = get_node("Sprite")
@onready var rayCast2D : RayCast2D = get_node("RayCast2D")

@export var move_speed = 50

var target_node = null
var home_pos = Vector2.ZERO

@onready var healthComponent = $HealthComponent
@onready var hitFlashAnimationPlayer = $HitFlashAnimationPlayer
@onready var navigationAgent : NavigationAgent2D = get_node("Navigation/NavigationAgent2D")
@onready var audioStream : AudioStreamPlayer2D = $AudioStreamPlayer2D

func _ready():
	healthComponent.hit.connect(_on_hit_flash)
	var __0 = connect("tree_exited", Callable(get_parent(),"on_boss_killed"))
	home_pos = self.global_position

	
func _physics_process(delta):
	if target_node != null:
		rotate_to_target(target_node, delta)
		
	
	
	var axis = to_local(navigationAgent.get_next_path_position()).normalized()
	velocity = axis * move_speed
		
	move_and_slide()
	
	if velocity.length() > 0:
		$AnimationPlayer.play("Walk")
	else:
		$AnimationPlayer.play("Idle")
		
		
	if velocity.x > 0:
		$Sprite.scale.x = 1
	else:
		$Sprite.scale.x = -1

	if navigationAgent.is_navigation_finished():
		return

func rotate_to_target(target, delta):
	var angle_to_target: float = global_position.direction_to(target.global_position + Vector2(0,20)).angle()
	rayCast2D.global_rotation = angle_to_target
	
	if rayCast2D.is_colliding():
		if mainSprite.scale.x > 0: weaponSprite.rotation = angle_to_target
		else: weaponSprite.rotation = -angle_to_target + PI
		gun_shoot()


func gun_shoot():
	if !can_shoot:
		return
		
	if !bullet:
		return
	
	can_shoot = false
	
	if counter == 3:
		bullet_number = 12
		bullet_angle = deg_to_rad(360)
		angle_offset = deg_to_rad(0)
	elif counter > 3:
		bullet_number = 12
		bullet_angle = deg_to_rad(360)
		angle_offset = deg_to_rad(45)
		counter = 0
	else:
		bullet_number = 3
		bullet_angle = deg_to_rad(25)
		angle_offset = deg_to_rad(0)
	
	for i in bullet_number:
		var new_bullet : Node2D = bullet.instantiate()
		new_bullet.position = endOfBarrel.global_position
		new_bullet.bullet_speed = bullet_speed
		new_bullet.bullet_damage = bullet_damage
		
		var arc_rad : float = bullet_angle
		var increment = arc_rad / (bullet_number - 1)
		new_bullet.global_rotation = (weaponSprite.global_rotation + angle_offset + increment * i - arc_rad / 2)
		
		
		get_tree().root.call_deferred("add_child", new_bullet)
		
	
	counter += 1
	audioStream.play()
	await get_tree().create_timer(fire_rate).timeout
	can_shoot = true


func _on_aggro_range_area_entered(area):
	target_node = area.owner


func _on_de_aggro_range_area_exited(area):
	if area.owner == target_node:
		target_node = null

func recalculate_path():
	if target_node:
		navigationAgent.target_position = target_node.global_position
	else:
		navigationAgent.target_position = home_pos

func _on_recalculate_timer_timeout():
	recalculate_path()

func _on_hit_flash():
	hitFlashAnimationPlayer.play("hit_flash")
