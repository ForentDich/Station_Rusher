extends CharacterBody2D
class_name Enemy

@export var move_speed = 50

var target_node = null
var home_pos = Vector2.ZERO

var navigationAgent : NavigationAgent2D

func _ready():
	_child_ready()
	var __0 = connect("tree_exited", Callable(get_parent(),"on_enemy_killed"))
	
	home_pos = self.global_position
	

func _child_ready():
	pass

func _physics_process(delta):
	_child_physics_process(delta)
	

	if velocity.length() > 0:
		$AnimationPlayer.play("Walk")
	else:
		$AnimationPlayer.play("Idle")
		
		
	if velocity.x > 0:
		$Sprite.scale.x = 1
	else:
		$Sprite.scale.x = -1

	

func _child_physics_process(delta):
	pass

func recalculate_path():
	if target_node:
		navigationAgent.target_position = target_node.global_position
	else:
		navigationAgent.target_position = home_pos


func _on_recalculate_timer_timeout():
	recalculate_path()


func _on_aggro_range_area_entered(area):
	target_node = area.owner

func _on_de_aggro_range_area_exited(area):
	if area.owner == target_node:
		target_node = null
