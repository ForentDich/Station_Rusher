extends CharacterBody2D
class_name Bullet

@onready var hitBoxCollider : Area2D = $HitboxCollider

var bullet_speed : float
var bullet_damage : int

var direction = Vector2.RIGHT

func _ready():
	direction = Vector2.RIGHT.rotated(global_rotation)
	
func _physics_process(delta):
	velocity = direction * bullet_speed
	var collision = move_and_collide(velocity * delta)
	if collision != null:
		self.queue_free()

func _on_hitbox_collider_area_entered(area):
	if area is HitboxComponent:
		var hitbox : HitboxComponent = area
		var attack = Attack.new()
		attack.attack_damage = bullet_damage
		hitbox.damage(attack)
		self.queue_free()
