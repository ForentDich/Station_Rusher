extends CharacterBody2D
class_name Player

const ACCELERATION : float = 2000
var FRICTION : float = 550
@export var MAX_SPEED : float = 120

var input_vector: Vector2 = Vector2.ZERO
var current_weapon: Weapon
var player_mask = 2


signal hp_changed
signal weapon_switched(prev_index, new_index)
signal weapon_picked_up(weapon_texture)
signal weapon_droped(index)

@onready var sprite: Node2D = $PlayerSprite
@onready var f_arm: Sprite2D = $PlayerSprite/Torso/Arm_F
@onready var b_arm: Sprite2D = $PlayerSprite/Torso/Arm_B
@onready var hand: Marker2D = $PlayerSprite/Torso/Arm_F/Hand
@onready var aim_b_arm: Marker2D = $PlayerSprite/Torso/Arm_F/AimArm_B
@onready var aim_pivot: Marker2D = $PlayerSprite/Torso/AimPivot
@onready var fsm: Node = $FSM
@onready var leg_anim: AnimationPlayer = $LegsAnimation
@onready var camera = $Camera2D
@onready var weapons: Node2D = $PlayerSprite/Torso/Arm_F/Hand/Weapons
@onready var audioStreamWalk : AudioStreamPlayer = $AudioStreamPlayer1
@onready var audioStreamPickUp : AudioStreamPlayer = $AudioStreamPlayer2

func _ready() -> void:
	current_weapon = weapons.get_child(0)
	SavedData.current_ammo = current_weapon.current_ammo
	SavedData.ammo_capacity = current_weapon.ammo_capacity
	emit_signal("weapon_picked_up", weapons.get_child(0).get_texture())
	SavedData.weapons.append(current_weapon.duplicate())
	print("-------------------------------------------------------- ", camera.is_current())
	await get_tree().process_frame
	if camera.is_current() == false:
		camera.make_current()

func get_input() -> void:
	if current_weapon.reloadTimer.is_stopped():
		if Input.is_action_just_released("switch_weapon"):
			switch_weapon()

			
		current_weapon.get_input()

func _play_step_audio():
	audioStreamWalk.play()

func move(delta):
	input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if input_vector == Vector2.ZERO:
		apply_friction(FRICTION * delta)
	else:
		apply_movement(input_vector * ACCELERATION * delta)
	move_and_slide()
	

func apply_friction(amount):
	if velocity.length() > amount:
		velocity -= velocity.normalized() * amount
	else:
		velocity = Vector2.ZERO

func apply_movement(amount):
	velocity += amount
	velocity = velocity.limit_length(MAX_SPEED)

func switch_weapon() -> void:
	var prev_index: int = current_weapon.get_index()
	var index: int = prev_index + 1
	if index > weapons.get_child_count() - 1:
		index = 0
		
	current_weapon.hide()
	current_weapon = weapons.get_child(index)
	current_weapon.show()
	SavedData.equipped_weapon_index = index
	SavedData.current_ammo = current_weapon.current_ammo
	SavedData.ammo_capacity = current_weapon.ammo_capacity
	
	emit_signal("weapon_switched", prev_index, index)

func drop_weapon() -> void:
	if SavedData.equipped_weapon_index == 0:
		switch_weapon()
	
	SavedData.weapons.remove_at(current_weapon.get_index())
	var weapon_to_drop: Node2D = current_weapon
	
	emit_signal("weapon_droped", weapon_to_drop.get_index())
	
	weapons.call_deferred("remove_child", weapon_to_drop)
	get_parent().call_deferred("add_child", weapon_to_drop)
	weapon_to_drop.interactionArea.set_collision_mask_value(player_mask, false)
	weapon_to_drop.set_owner(get_parent())
	await weapon_to_drop.tree_entered
	weapon_to_drop.show()
	
	var throw_dir: Vector2 = (get_global_mouse_position() - position).normalized()
	weapon_to_drop.rotation = throw_dir.angle()
	weapon_to_drop.flip_weapon(throw_dir)
	weapon_to_drop.interpolate_position(hand.global_position, hand.global_position + throw_dir * 50)

func pick_up_weapon(weapon: Node2D) -> void:
	SavedData.weapons.append(weapon.duplicate())
	var prev_index: int = SavedData.equipped_weapon_index
	var new_index: int = weapons.get_child_count()
	SavedData.equipped_weapon_index = new_index
	weapon.get_parent().call_deferred("remove_child", weapon)
	weapon.rotation = 0
	weapon.scale.y = abs(weapon.scale.y)
	weapons.call_deferred("add_child", weapon)
	weapon.set_deferred("owner", weapons)
	current_weapon.hide()
	current_weapon = weapon
	current_weapon.show()
	
	audioStreamPickUp.play()
	
	SavedData.ammo_capacity = weapon.ammo_capacity
	SavedData.current_ammo = weapon.current_ammo
	
	emit_signal("weapon_picked_up", weapon.get_texture())
	emit_signal("weapon_switched", prev_index, new_index)

func aim(pos: Vector2) -> void:
	flip_player_sprite(pos.x < self.global_position.x)
	if (pos.x < self.global_position.x):
		f_arm.rotation = -(aim_pivot.global_position - pos).angle()
	else:
		f_arm.rotation = (pos - aim_pivot.global_position).angle()
	b_arm.look_at(aim_b_arm.global_position)

func flip_player_sprite(flip: bool) -> void:
	match flip:
		true: sprite.scale.x = -1
		false: sprite.scale.x = 1

func animate_legs() -> void:
	if (input_vector == Vector2.ZERO):
		leg_anim.play("Idle")
	else:
		var is_forward: bool = (sprite.scale.x == 1 and (input_vector.x > 0 or -input_vector.y > 0)) or (sprite.scale.x == -1 and (input_vector.x < 0 or input_vector.y < 0))
		match is_forward:
			true: leg_anim.play("Walk_Forward")
			false: leg_anim.play("Walk_Backward")
