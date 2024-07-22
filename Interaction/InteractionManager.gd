extends Node2D

@onready var player = get_tree().get_first_node_in_group("Player")
@onready var ui : UI = get_tree().get_first_node_in_group("UI")
#@onready var label = $Label

func _ready():
	get_tree().node_added.connect(func(_node):
		player = get_tree().get_first_node_in_group("Player")
		ui = get_tree().get_first_node_in_group("UI")
	)

const base_text = "[E] "

var active_areas = []
var can_interact = true
var last_area = []

func register_area(area : InteractionArea):
	active_areas.push_back(area)
	
func unregister_area(area : InteractionArea):
	var index = active_areas.find(area)
	if index != -1:
		active_areas[index].sprite_for_shader.material.set_shader_parameter("on", false)
		active_areas.remove_at(index)
		
func _process(delta):
	if !get_tree().current_scene.is_in_group("CanUI"):
		return
	
	if active_areas.size() > 0 && can_interact:
		active_areas.sort_custom(_sort_by_distance_to_player)
		last_area = active_areas.duplicate()
		last_area[0].sprite_for_shader.material.set_shader_parameter("on", true)
		if active_areas.size() > 1:
			last_area.slice(1).map(func(element): element.sprite_for_shader.material.set_shader_parameter("on", false))
		
		ui.labelAdvice.text = base_text + active_areas[0].action_name
		ui.labelAdvice.show()
		'''
		label.text = base_text + active_areas[0].action_name
		label.global_position = active_areas[0].global_position
		label.global_position.y -= 36
		label.global_position.x -= label.size.x * label.scale.x / 2
		label.show()
		'''
	else:
		ui.labelAdvice.hide()
		

func _sort_by_distance_to_player(area1, area2):
	var area1_to_player = player.global_position.distance_to(area1.global_position)
	var area2_to_player = player.global_position.distance_to(area2.global_position)
	return area1_to_player < area2_to_player


func _input(event):
	if event.is_action_pressed("interact") && can_interact:
		if active_areas.size() > 0:
			can_interact = false
			#label.hide()
			
			await active_areas[0].interact.call()
			can_interact = true
	
