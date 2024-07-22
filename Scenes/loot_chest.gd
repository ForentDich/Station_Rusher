extends StaticBody2D

@onready var weapons = [
	preload("res://Scenes/pm_start.tscn"),
	preload("res://Scenes/StartShootgun.tscn"),
	preload("res://Scenes/common_rifle.tscn"),
]


@onready var interactionArea = $InteractionArea
@onready var sprite = $Sprite2D

func _ready():
	sprite.frame = 0
	interactionArea.interact = Callable(self, "_open")
	
func _open():
	interactionArea.queue_free()
	sprite.material.set_shader_parameter("on", false)
	sprite.frame = 1
	
	spawn_weapon()

func spawn_weapon():
	
	var r = randi_range(0, weapons.size() - 1)
	var new_weapon = weapons[r].instantiate()
	print(new_weapon.interactionArea)
	new_weapon.position = position
	new_weapon.on_floor = true
	
	get_parent().call_deferred("add_child", new_weapon)
	new_weapon.set_owner(get_parent())
	

	var throw_dir: Vector2 = Vector2(randf(), randf())
	new_weapon.rotation = throw_dir.angle()
	new_weapon.flip_weapon(throw_dir)

	print(new_weapon.interactionArea)
	print(new_weapon.interactionArea)
	print(new_weapon.interactionArea)
	print(new_weapon.interactionArea)
