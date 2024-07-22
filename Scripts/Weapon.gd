extends Node2D
class_name Weapon

@export var weapon_data: WeaponResource
@export var on_floor: bool = false

const INT64_MAX = 10**7

var player : CharacterBody2D
var is_empty : bool = false
var can_shoot : bool = true
var can_pickup : bool = true
var current_ammo : int = 0
var ammo_capacity : int = 0
var tween: Tween = null
var intArea : Area2D

var player_mask = 2

@onready var bullet_path = preload("res://Scenes/bullet.tscn")
@onready var barrelOrigin := $Base/BarrelOrigin
@onready var reloadTimer : Timer = $ReloadTimer
@onready var interactionArea : Area2D = $InteractionArea
@onready var audioStream : AudioStreamPlayer2D = $AudioStreamPlayer2D

func _ready() -> void:
	interactionArea.interact = Callable(self, "replace_weapon")
	if on_floor == false:
		interactionArea.set_collision_mask_value(player_mask, false)
				
	reloadTimer.timeout.connect(refill_ammo)
	current_ammo = weapon_data.magazine_size
	ammo_capacity = weapon_data.ammo_capacity
	
	var is_infinity = weapon_data.is_infinite_ammo_capacity
	if is_infinity:
		ammo_capacity = INT64_MAX
	
	await get_tree().process_frame
	intArea = interactionArea

func _physics_process(delta) -> void:
	if current_ammo == 0 and reloadTimer.is_stopped() and is_empty == false:
		gun_reload()

func get_input():
	if is_empty == false:
		if Input.is_action_pressed("first_attack") and reloadTimer.is_stopped():
			gun_fire()
		
func gun_fire() -> void:
	if !can_shoot:
		return
		
	can_shoot = false		
	current_ammo -= 1
	SavedData.current_ammo = current_ammo
				
	for i in weapon_data.bullet_number:
		var new_bullet = bullet_path.instantiate()
		new_bullet.position = barrelOrigin.global_position
		new_bullet.bullet_speed = weapon_data.bullet_speed
		new_bullet.bullet_damage = weapon_data.damage
					
		if weapon_data.bullet_number == 1:
			new_bullet.rotation = global_rotation
		else:
			var arc_rad = weapon_data.bullet_max_angle
			var increment = arc_rad / (weapon_data.bullet_number - 1)
			new_bullet.global_rotation = (global_rotation + increment * i - arc_rad / 2)
						
		get_tree().root.call_deferred("add_child", new_bullet)
	
	audioStream.play()
	await get_tree().create_timer(weapon_data.fire_rate).timeout
	can_shoot = true
		
func gun_reload() -> void:
	if ammo_capacity <= 0:
		is_empty = true
		return
		
	reloadTimer.start(weapon_data.reload_time)
	
func refill_ammo():
	var missing_ammo : int = weapon_data.magazine_size - current_ammo
	
	if ammo_capacity >= missing_ammo:
		ammo_capacity -= missing_ammo
		current_ammo =  weapon_data.magazine_size
	else:
		current_ammo += ammo_capacity
		ammo_capacity = 0
		
	SavedData.ammo_capacity = ammo_capacity
	SavedData.current_ammo = current_ammo

func interpolate_position(initial_position: Vector2, final_position: Vector2):
	position = initial_position
	tween = create_tween()
	tween.tween_property(self, "position", final_position, 0.5).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	tween.connect("finished", _on_Tween_tween_completed)
	interactionArea.set_collision_mask_value(player_mask, true)

func flip_weapon(mouse_direction: Vector2) -> void:
	if scale.y > 0 and mouse_direction.x < 0:
		scale.y *= -1
	elif scale.y < 0 and mouse_direction.x > 0:
		scale.y *= -1


func replace_weapon():
	if player:
		if !can_pickup:
			return
		
		can_pickup = false
		
		interactionArea.set_collision_mask_value(player_mask, false)
		if SavedData.weapons.size() == SavedData.inventory_max_size:
			player.drop_weapon()
		player.pick_up_weapon(self)
		position = Vector2.ZERO
		print(SavedData.weapons)	
		await get_tree().create_timer(0.6).timeout
		
		can_pickup = true


func _on_Tween_tween_completed() -> void:
	interactionArea.set_collision_mask_value(player_mask, true)

	
func get_texture() -> Texture2D:
	return get_node("Base/WeaponSprite").texture


func _on_interaction_area_body_entered(body):
	if body is Player:
		player = body
