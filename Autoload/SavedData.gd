extends Node

var HP: int = 8

var current_ammo : int = 0
var ammo_capacity : int = 0

var weapons: Array = []
var ui_weapons: Array = []
var equipped_weapon_index: int = 0
var inventory_max_size: int = 3

func reset_data() -> void:
	HP = 8
	weapons = []
	ui_weapons = []
	equipped_weapon_index = 0
