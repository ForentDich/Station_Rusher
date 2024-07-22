extends Node
class_name RoomFactory

var room_index : int

func generate_room(index: int):
	return get_child(index).duplicate()

func get_room_ports_position(index : int, direction : Vector2):
	var node_ports : Node2D = get_child(index).get_node("Ports")
	var node_ports_side : Node2D
	var ports_position_array : Array = []
	
	match direction:
		Vector2.LEFT: node_ports_side = node_ports.get_node("LEFT")
		Vector2.UP: node_ports_side = node_ports.get_node("UP")
		Vector2.RIGHT: node_ports_side = node_ports.get_node("RIGHT")
		Vector2.DOWN: node_ports_side = node_ports.get_node("DOWN")
		_: print("Error in get_room_ports_position()")

	for i in node_ports_side.get_child_count():
		ports_position_array.append(node_ports_side.get_child(i).position)
		
	return ports_position_array

func get_room_in_area(node) -> bool:
	if (node.get_node("CheckArea2D").get_overlapping_areas().size() != 0):
		return true
	else:
		return false
		
func get_room_index_array():
	var index_array = []
	for i in get_child_count():
		index_array.append(i)
	return index_array
	
func change_room_tiles(node : Node2D) -> void:
	var node_tilemap = node.get_node("TileMap")
	var node_tilemap_position : Vector2 = node_tilemap.position
	var node_ports : Node2D = node.get_node("Ports")
	var node_doors : Node2D = node.get_node("Doors")
	
	var coords_modifier : Vector2i
	var atlas_array : Array = []
	var fill_length : int
	var layer_num
	var source_id : int
	var alt_index : int
	var door_offset : Vector2 = Vector2.ZERO
	
	var set_cell_in_loop = func (layer_num : int, source_id : int, coords : Vector2i, length : int, atlas_coords_array : Array, alternative : int):
		for i in atlas_coords_array.size():
			for j in length:
				node_tilemap.set_cell(layer_num, coords + Vector2i(j, i), source_id, atlas_coords_array[i], alternative)
	
	var get_distance_port = func (tilemap_node_pos : Vector2, port_pos : Vector2):
		return Vector2i(-tilemap_node_pos + port_pos) / GlobalGeneration.PIXEL
	
	for i in node_ports.get_child_count():
		var side = node_ports.get_child(i)
		
		match side.name:
			"LEFT": coords_modifier = Vector2i(0,-4); atlas_array.resize(5); atlas_array.fill(Vector2i(2,0)); fill_length = 1; layer_num = 1; source_id = 1; alt_index = 2; door_offset = Vector2(GlobalGeneration.PIXEL / 2, 0)
			"RIGHT": coords_modifier = Vector2i(-1,-4); atlas_array.resize(5); atlas_array.fill(Vector2i(2,0)); fill_length = 1; layer_num = 1; source_id = 1;  alt_index = 2; door_offset = Vector2(-(GlobalGeneration.PIXEL / 2), 0)
			"UP": coords_modifier = Vector2i(-2,-2); atlas_array = [Vector2i(2,1), Vector2i(0,4), Vector2i(9,4)]; fill_length = 4; layer_num = 1; source_id = 1;  alt_index = 0; door_offset = Vector2(0, GlobalGeneration.PIXEL)
			"DOWN": coords_modifier = Vector2i(-2, -3); atlas_array = [Vector2i(2,1), Vector2i(1,2), Vector2i(8,3)]; fill_length = 4; layer_num = 2; source_id = 0; alt_index = 0; door_offset = Vector2.ZERO
				
		for j in node_ports.get_child(i).get_child_count():
			var port = node_ports.get_child(i).get_child(j)
			var port_distance = get_distance_port.call(node_tilemap_position, port.position)
			if (port.get_node("CheckEntArea2D").get_overlapping_areas().size() == 0):
				set_cell_in_loop.call(layer_num, source_id, port_distance + coords_modifier, fill_length, atlas_array, alt_index)
			else:
				if side.name == "UP" or side.name == "DOWN":
					generate_door(node_doors, 0, port.position + door_offset)
				else:
					generate_door(node_doors, 1, port.position + door_offset)


func generate_door(node : Node2D, type : int, pos : Vector2) -> void:
	var new_door : Node2D
	match type:
		0: new_door = GlobalGeneration.door_front.instantiate()
		1: new_door = GlobalGeneration.door_side.instantiate()
	new_door.position = pos
	node.add_child(new_door)
	#get_child_count - узнать количество комнат
