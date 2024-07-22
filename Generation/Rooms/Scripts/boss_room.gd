extends Node2D
class_name BossRoom

var direction : Vector2 = Vector2.RIGHT
var index : int
var new_door : Node2D

@onready var corridors = [$Corridors/Down, $Corridors/Left, $Corridors/Right]
@onready var door_markers = [$Doors/Down, $Doors/Left, $Doors/Right]
@onready var tileMap = %TileMap
@onready var playerArea = %PlayerArea
@onready var doors = %Doors
@onready var ui = get_node("/root/World/UI")

const SPAWN_EXPLOSION: PackedScene = preload("res://Scenes/spawn_explosion.tscn")

func _ready():
	print(ui)
	playerArea.connect("body_entered",Callable(self, "_on_player_enter"))
	GlobalGeneration.connect("open_boss_room", Callable(self, "open_doors"))
	
	match direction:
		Vector2.UP: 
			corridors[1].queue_free(); corridors[2].queue_free()
			index = 0
		Vector2.RIGHT: 
			corridors[0].queue_free(); corridors[2].queue_free()
			index = 1
		Vector2.LEFT: 
			corridors[0].queue_free(); corridors[1].queue_free()
			index = 2
	
	var c = 2
	for i in 3:
		if i == index:	
			tileMap.set_layer_enabled(c + 1, true)
		else:
			tileMap.set_layer_enabled(c, true)	
		c += 2
		
	
	if index != 0:
		new_door = GlobalGeneration.door_side.instantiate()
	else:
		new_door = GlobalGeneration.door_front.instantiate()
	new_door.position = door_markers[index].position
	add_child(new_door)
	
	close_doors()

func open_doors() -> void:
	new_door.unlock()

func close_doors() -> void:
	new_door.lock()


func on_boss_killed():
	if GlobalGeneration.level_completed == false:
		return
	
	StatData.total_time += ui.time
	ui.call("_on_stop_timer")
	StatData.level_completed += 1
	StatData.rooms_cleared += GlobalGeneration.rooms_cleared
	StatData.robots_destroyed += GlobalGeneration.robots_destroyed
	
	ui.call("return_timer")
	await get_tree().create_timer(14).timeout
	SceneTransistor.switch_scene("res://ship.tscn")
	Utils.save_game(Utils.current_slot)
	SavedData.reset_data()
	GlobalGeneration.level_completed == false

func _on_player_enter(body):
	playerArea.queue_free()
	close_doors()
	print("Он вошёл")
	
	var new_boss = GlobalGeneration.boss_alpha.instantiate()
	call_deferred("add_child", new_boss)
		
	var spawn_explosion: AnimatedSprite2D = SPAWN_EXPLOSION.instantiate()
	call_deferred("add_child", spawn_explosion)
