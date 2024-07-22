extends Node2D
		
@onready var tilemap_wall = $TileMapWall
@onready var tilemap_floor = $TileMapFloor

var direction_of_corridor = Vector2.UP
var corridor_node_direction : Vector2
var current_position = Vector2.ZERO
var target_position = Vector2.ZERO
var type_of_corridor = [GlobalGeneration.min_size_corridor, GlobalGeneration.med_size_corridor, GlobalGeneration.max_size_corridor]

var cross_segment = GlobalGeneration.cross_segment
var corridor_segment = GlobalGeneration.corridor_segment
var entrance_factory = GlobalGeneration.entrance_factory.instantiate()
var room_factory = GlobalGeneration.room_factory.instantiate()
var shutter_factory = GlobalGeneration.shutter_factory.instantiate()
var boss_room = GlobalGeneration.boss_room.instantiate()
var rooms_index_array = room_factory.get_room_index_array()


func change_corridor_layers(node):
	var areas_array = [
		node.get_node("SimpleArea2D/UP"),
		node.get_node("SimpleArea2D/DOWN"),
		node.get_node("SimpleArea2D/LEFT"),
		node.get_node("SimpleArea2D/RIGHT")]
	
	var tile_map_wall = node.get_node("TileMapWall")
	var c = 2
	for i in 4:
		if (areas_array[i].get_overlapping_areas().size() != 0):
			tile_map_wall.set_layer_enabled(c - 1, false)
			tile_map_wall.set_layer_enabled(c, true)	
		c += 2


func enable_layers_on_direction(direction : Vector2):
	if direction == Vector2.UP:
		tilemap_wall.set_layer_enabled(5, true)
		tilemap_wall.set_layer_enabled(7, true)
	else:
		tilemap_wall.set_layer_enabled(1, true)
		tilemap_wall.set_layer_enabled(3, true)


func generate_corridor():
	var instance : Node2D = corridor_segment.instantiate()
	current_position = target_position
	target_position = current_position + direction_of_corridor * GlobalGeneration.VECTOR_MODIFIER_CS
	instance.position = target_position
	get_parent().add_child(instance)
	instance.direction_of_corridor = direction_of_corridor
	instance.rotate_tilemap()
	instance.add_to_group("Corridor_segment_list")
	instance.enable_layers_on_direction(direction_of_corridor)


func generate_line_of_corridor():
	var r : int = type_of_corridor[randi() % type_of_corridor.size()]
	for i in r - 1:
		generate_corridor()
		await get_tree().create_timer(0.1).timeout		
		if i % 3 == 0:
			generate_entrance_from_corridor(true)
		else:
			generate_entrance_from_corridor(false)
			
	await get_tree().create_timer(0.1).timeout
	if GlobalGeneration.is_cross_limit == false:
		generate_cross_from_corridor(-direction_of_corridor)
	else:
		add_to_group("Last_corridor_list")

func generate_cross_from_corridor(unused_direction : Vector2):
	var instance = cross_segment.instantiate()
	target_position = current_position + direction_of_corridor * GlobalGeneration.VECTOR_MODIFIER_CS
	instance.position = target_position
	instance.direction_closed = unused_direction
	add_child(instance)
	instance.add_to_group("Cross_segment_list")
	await get_tree().physics_frame


func generate_boss_room():
	var new_boss_room = boss_room
	new_boss_room.direction = direction_of_corridor
	new_boss_room.position = target_position + direction_of_corridor * GlobalGeneration.PIXEL * 21
	get_parent().add_child(new_boss_room)
	
	
func generate_shutter():
	var new_shutter : Node2D
	match direction_of_corridor:
		Vector2.UP:  new_shutter = shutter_factory.generate_shutter(1)
		Vector2.LEFT: new_shutter = shutter_factory.generate_shutter(0)
		Vector2.RIGHT: new_shutter = shutter_factory.generate_shutter(0); new_shutter.scale.x = -1
	new_shutter.position = target_position + (direction_of_corridor * 16) + (direction_of_corridor * GlobalGeneration.PIXEL * 3)
	get_parent().add_child(new_shutter)


func generate_entrance_from_corridor(with_room : bool):
	var set_entrance_instance = func(index, direction):
		var instance = entrance_factory.generate_entrance(index)
		instance.position = target_position + direction * GlobalGeneration.VECTOR_MODIFIER_CE
		get_parent().add_child(instance)
		instance.add_to_group("Entrance_list")
		if with_room:
			await get_tree().create_timer(1.1).timeout
			await generate_room_from_corridor(instance.position, direction)
	
	match direction_of_corridor:
		Vector2.UP:
			set_entrance_instance.call(0, Vector2.LEFT)
			set_entrance_instance.call(0, Vector2.RIGHT)
		_:
			set_entrance_instance.call(1, Vector2.UP)
			set_entrance_instance.call(1, Vector2.DOWN)


func generate_room_from_corridor(pos : Vector2, direction : Vector2):
	var index_array : Array = rooms_index_array
	index_array.shuffle()
	index_array.reverse()
	var new_room : Node2D
	
	for i in index_array:
		new_room = room_factory.generate_room(i) 
		var new_room_port : Array = room_factory.get_room_ports_position(i , -direction)
		new_room.position = pos + direction * Vector2(64,64) - new_room_port.pop_back()
		get_parent().add_child(new_room)
		await get_tree().create_timer(0.2).timeout
		var is_room_in_area = room_factory.get_room_in_area(new_room)
		
		if is_room_in_area == true and new_room_port.size() != 0:
			new_room.position = pos + direction * Vector2(64,64) - new_room_port.pop_back()
		if is_room_in_area == true:
			new_room.queue_free()
		else:
			new_room.add_to_group("Room_list")
			break


func rotate_tilemap() -> void:
	tilemap_floor.rotation = direction_of_corridor.angle() + PI/2
