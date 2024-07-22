extends Node2D
class_name CommonRoom

@export_range(0, 100, 1) var min_num_enemies : int
@export_range(0, 100, 1) var max_num_enemies : int

const SPAWN_EXPLOSION: PackedScene = preload("res://Scenes/spawn_explosion.tscn")
const LOOT_CHEST: PackedScene = preload("res://Scenes/loot_chest.tscn")

var num_enemies : int

@onready var tileMap : TileMap = get_node("TileMap")
@onready var door_container: Node2D = get_node("Doors")
@onready var playerDetector: Area2D = get_node("PlayerDetector")
@onready var enemiesArea: ReferenceRect = get_node("EnemiesArea")
@onready var checkArea: Area2D = get_node("CheckArea2D")

func _ready():
	num_enemies = randi_range(min_num_enemies, max_num_enemies)
	playerDetector.connect("body_entered", Callable(self,"on_player_enter"))
	checkArea.connect("area_entered", Callable(self, "_on_area_entered"))
	
func on_enemy_killed() -> void:
	num_enemies -= 1
	GlobalGeneration.robots_destroyed += 1
	if num_enemies == 0:
		open_doors()
		spawn_chest()
		print(GlobalGeneration.amount_of_rooms)
		GlobalGeneration.amount_of_rooms -= 1
		GlobalGeneration.rooms_cleared += 1
		
		if GlobalGeneration.amount_of_rooms == 0:
			GlobalGeneration.emit_signal("open_boss_room")
		
func open_doors() -> void:
	for door in door_container.get_children():
		door.unlock()

func close_doors() -> void:
	for door in door_container.get_children():
		door.lock()
		
func spawn_enemies() -> void:
	for i in num_enemies:
		await get_tree().create_timer(randf_range(0.01, 0.20)).timeout
		var spawn_position : Vector2 = enemiesArea.position + Vector2(randf() * enemiesArea.size.x, randf() * enemiesArea.size.y)
		var enemy_scene = GlobalGeneration.ENEMY_SCENES[GlobalGeneration.ENEMY_SCENES.keys().pick_random()]
		var enemy : CharacterBody2D = enemy_scene.instantiate()
		enemy.position = spawn_position
		call_deferred("add_child", enemy)
		
		var spawn_explosion: AnimatedSprite2D = SPAWN_EXPLOSION.instantiate()
		spawn_explosion.position = spawn_position
		call_deferred("add_child", spawn_explosion)
		
	
func spawn_chest() -> void:
	var chest = LOOT_CHEST.instantiate()
	chest.position = enemiesArea.position + Vector2(enemiesArea.size.x / 2, enemiesArea.size.y / 2)
	call_deferred("add_child", chest)

func on_player_enter(body):
	playerDetector.queue_free()
	if num_enemies > 0:
		close_doors()
		spawn_enemies()
	else:
		spawn_chest()
		open_doors()

func _on_area_entered(area):
	if area.collision_layer == 2048: #12 layer
		queue_free()
