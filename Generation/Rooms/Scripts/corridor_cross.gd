extends Node2D

var corridor_segment = GlobalGeneration.corridor_segment
var directions = GlobalGeneration.DIRECTIONS_NODOWN.duplicate()
var direction_closed : Vector2
var directions_to_generate : Array

const SPAWN_EXPLOSION: PackedScene = preload("res://Scenes/spawn_explosion.tscn")

@onready var playerDetector: Area2D = get_node("PlayerDetector")
@onready var enemiesArea: ReferenceRect = get_node("EnemiesArea")
@onready var area_collision_shape_array : Array = [
	get_node("CheckerArea2D/UP/CollisionShape2D"),
	get_node("CheckerArea2D/DOWN/CollisionShape2D"),
	get_node("CheckerArea2D/LEFT/CollisionShape2D"),
	get_node("CheckerArea2D/RIGHT/CollisionShape2D")]

func _ready():
	set_collision_shape_map()
	await get_tree().create_timer(0.1).timeout
	set_side_to_generate_corridor()
	for i in directions_to_generate:
		await get_tree().physics_frame
		generate_corridor_segment(i)
		await get_tree().physics_frame
	
	playerDetector.connect("body_entered", Callable(self,"on_player_enter"))

func change_cross_layers(node):
	var areas_array = [node.get_node("SimpleArea2D/UP"),
	node.get_node("SimpleArea2D/DOWN"),
	node.get_node("SimpleArea2D/LEFT"),
	node.get_node("SimpleArea2D/RIGHT")]
	
	var tile_map_wall = node.get_node("TileMapWall")
	var c = 2
	for i in 4:
		if (areas_array[i].get_overlapping_areas().size() != 0):		
			tile_map_wall.set_layer_enabled(c, true)
		else:
			tile_map_wall.set_layer_enabled(c - 1, true)	
		c += 2


func set_side_to_generate_corridor():
	var roll = randf()
	var rang : int
	
	directions.erase(direction_closed)
	area_collision_shape_array.map(set_area_parameters_map)
	rang = set_range_with_chance(directions.size(), roll)
	
	var find_and_pop = func (array : Array, seek):
		var index = array.find(seek)
		return array.pop_at(index)
	
	directions.shuffle()
	for i in rang:
		directions_to_generate.append(directions[i])
		
		
	
	'''
	for i in rang: #Сколько выходов #Не осуждайте вдвойне
		roll = randf()
		print(roll)
		if roll < GlobalGeneration.chance_to_up_direction and directions.has(Vector2.UP):
			directions_to_generate.append(find_and_pop.call(directions, Vector2.UP))
		elif directions.has(Vector2.LEFT) or directions.has(Vector2.RIGHT):
			roll = randf()
			if roll < 0.5 and directions.has(Vector2.LEFT):
				directions_to_generate.append(find_and_pop.call(directions, Vector2.LEFT))
			elif directions.has(Vector2.RIGHT):
				directions_to_generate.append(find_and_pop.call(directions, Vector2.RIGHT))
	
	'''

func set_range_with_chance(x, roll):
	match x:
		1: return 1
		2: return 1 if roll < GlobalGeneration.one_side_two_direction else 2
		3: return 1 if roll < GlobalGeneration.one_side_three_direction else 2 if roll < GlobalGeneration.two_side_three_direction else 3
		_: print("ERROR in set_range_with_chance")


func set_area_parameters_map(element):
	element.set_deferred("debug_color", Color(1,1,1,1))
	element.set_deferred("disabled", true)


func generate_corridor_segment(direction):
	var instance = corridor_segment.instantiate()
	instance.position = direction * GlobalGeneration.COORDINATE_SYSTEM_CC
	add_child(instance)
	instance.add_to_group("Corridor_segment_list")
	instance.direction_of_corridor = direction
	instance.target_position = instance.position
	instance.rotate_tilemap()
	instance.enable_layers_on_direction(direction)
	instance.generate_line_of_corridor()

	
func set_collision_shape_map():
	var directions_map_array : Array = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]
	area_collision_shape_array.map(func(element): element.shape.set_b(directions_map_array[area_collision_shape_array.find(element)] * GlobalGeneration.COORDINATE_SYSTEM_CS * GlobalGeneration.max_size_corridor * GlobalGeneration.LINE_MODIFIER))
	await get_tree().process_frame


func spawn_enemy():
	await get_tree().create_timer(randf_range(0.01, 0.20)).timeout
	var spawn_position : Vector2 = enemiesArea.position + Vector2(randf() * enemiesArea.size.x, randf() * enemiesArea.size.y)
	var enemy_scene = GlobalGeneration.ENEMY_SCENES[GlobalGeneration.ENEMY_SCENES.keys().pick_random()]
	var enemy : CharacterBody2D = enemy_scene.instantiate()
	enemy.position = spawn_position
	call_deferred("add_child", enemy)
		
	var spawn_explosion: AnimatedSprite2D = SPAWN_EXPLOSION.instantiate()
	spawn_explosion.position = spawn_position
	call_deferred("add_child", spawn_explosion)

func on_player_enter(body):
	playerDetector.queue_free()
	spawn_enemy()


func set_area_parameters(shapes_array : Array, index : int):
	shapes_array[index].set_deferred("debug_color", Color(1,1,1,1))
	shapes_array[index].set_deferred("disabled", true)


func _on_up_area_entered(area):
	set_area_parameters(area_collision_shape_array, 0)
	directions.erase(Vector2.UP)
	
func _on_down_area_entered(area):
	set_area_parameters(area_collision_shape_array, 1)
	directions.erase(Vector2.DOWN)
	
func _on_left_area_entered(area):
	set_area_parameters(area_collision_shape_array, 2)
	directions.erase(Vector2.LEFT)
	
func _on_right_area_entered(area):
	set_area_parameters(area_collision_shape_array, 3)
	directions.erase(Vector2.RIGHT)
	

