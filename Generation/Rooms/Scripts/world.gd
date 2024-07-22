extends Node2D

const STATION_STYLE_TEXTURES = [
	"res://Generation/Sprites/station_style_0.png"
]

const STATION_ROOM_TEXTURES = [
	"res://Generation/Sprites/station_room_0.png"
]

var is_end_for_process : bool = true
var style : int = 0
var room : int = 0
var paused = false

@onready var entrance_factory = GlobalGeneration.entrance_factory.instantiate()
@onready var cross_segment = GlobalGeneration.cross_segment.instantiate()
@onready var corridor_segment = GlobalGeneration.corridor_segment.instantiate()
@onready var room_factory = GlobalGeneration.room_factory.instantiate()
@onready var ui = $UI
@onready var pauseMenu = $PauseMenu

func _ready():
	randomize()
	generate_cross(Vector2(0, -1088))


func pause_menu():
	if paused:
		pauseMenu.hide()
		get_tree().paused = false
	else:
		pauseMenu.show()
		get_tree().paused = true
		
	paused = !paused


func _process(delta):
	if Input.is_action_just_pressed("pause"):
		pause_menu()
	
	if get_tree().get_nodes_in_group("Cross_segment_list").size() >= GlobalGeneration.amount_of_cross:
		GlobalGeneration.is_cross_limit = true
	
		
	call_end()
		

func call_end():
	if GlobalGeneration.is_cross_limit == true and is_end_for_process == true:
		is_end_for_process = false
		
		await get_tree().create_timer(4.5).timeout
		
		var far_corridor = get_far_corridor()
		far_corridor.generate_boss_room()
		
		await get_tree().create_timer(0.1).timeout
		
		for cor in get_tree().get_nodes_in_group("Last_corridor_list"):
			cor.generate_shutter()
		
		await get_tree().create_timer(0.1).timeout
		group_method("Entrance_list", entrance_factory, "delete_entrance_in_area")
		await get_tree().create_timer(0.1).timeout
		group_method("Corridor_segment_list", corridor_segment, "change_corridor_layers")
		
		
		
		group_method("Cross_segment_list", cross_segment, "change_cross_layers")
		group_method("Room_list", room_factory, "change_room_tiles") 


		var texture = load(STATION_STYLE_TEXTURES[style])
		$TileMap.tile_set.get_source(0).texture = texture
		var texture2 = load(STATION_ROOM_TEXTURES[room])
		$TileMap.tile_set.get_source(1).texture = texture2
		
		GlobalGeneration.amount_of_rooms = get_tree().get_nodes_in_group("Room_list").size()
		
		ui.timer.show() 
		ui.rooms.show()
		SceneTransistor.can_show.emit()
		ui.timer_can_start.emit()

func group_method(group_name : String, global_node, method_name : String):
	var group = get_tree().get_nodes_in_group(group_name)
	for i in group:
		global_node.call(method_name, i)

func get_far_corridor():
	var far_corridor = null
	var far_distance = 0
	for corridor in get_tree().get_nodes_in_group("Last_corridor_list"):
		var distance = Vector2(0,0).distance_to(corridor.global_position)
		if distance > far_distance:
			far_distance = distance
			far_corridor = corridor
	
	far_corridor.remove_from_group("Last_corridor_list")
	return far_corridor


func generate_cross(pos):
	var instance = GlobalGeneration.cross_segment.instantiate()
	instance.position = pos
	add_child(instance)
	instance.add_to_group("Cross_segment_list")

