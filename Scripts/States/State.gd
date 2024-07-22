extends Node
class_name State

signal Transitioned

@export var enemy : CharacterBody2D
@export var move_speed := 10.0
@export var spot_range := 25.0

func _ready():
	spot_range *= 32

func enter():
	pass
	
func exit():
	pass
	
func state_update(_delta : float):
	pass
	
func state_physics_update(_delta : float):
	pass
