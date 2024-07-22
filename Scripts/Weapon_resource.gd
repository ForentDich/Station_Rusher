class_name WeaponResource extends Resource

@export var id: String
@export var weapon_name: String

@export_enum("Обычное","Редкое") var rarity: int

@export var accuracy: float
@export var magazine_size: int
@export var is_infinite_ammo_capacity: bool
@export var ammo_capacity: int
@export var damage: int
@export var knockback: int
@export var camera_shake: int
@export var fire_rate: float
@export var reload_time: float
@export var bullet_speed: float
@export var bullet_number: int
@export_range(0, 360, 0.001, "radians_as_degrees") var bullet_max_angle: float
@export var bullet_range: float



signal item_used

func use_item():
	item_used.emit()
