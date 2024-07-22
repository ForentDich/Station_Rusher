extends Node

signal open_boss_room
# Генерация ------------------
var min_size_corridor : int = 3
var med_size_corridor : int = 6
var max_size_corridor : int = 9

var one_side_two_direction : float = 0.4 # всегда возрастание, через if-else вероятность
var one_side_three_direction : float = 0.45 #ну
var two_side_three_direction : float = 0.7
var chance_to_up_direction : float = 0.4

var amount_of_cross : int = 2 #4
var is_cross_limit : bool = false

var level_completed : bool = false

var amount_of_rooms : int = 0
var rooms_cleared : int = 0
var robots_destroyed: int = 0

# Типо системы координат----------
const PIXEL : int = 32
const COORDINATE_SYSTEM_CE = PIXEL * 5
const VECTOR_MODIFIER_CE = Vector2(COORDINATE_SYSTEM_CE,COORDINATE_SYSTEM_CE)
const COORDINATE_SYSTEM_CS = PIXEL * 6
const VECTOR_MODIFIER_CS = Vector2(COORDINATE_SYSTEM_CS,COORDINATE_SYSTEM_CS)
const COORDINATE_SYSTEM_CC = PIXEL * 7
const VECTOR_MODIFIER_CC = Vector2(COORDINATE_SYSTEM_CC,COORDINATE_SYSTEM_CC)
const DIRECTIONS_NODOWN = [Vector2.UP, Vector2.LEFT, Vector2.RIGHT]
const LINE_MODIFIER = 1.5
#--------------------------------
@onready var corridor_segment = preload("res://Generation/Rooms/Scenes/corridor_segment.tscn")
@onready var cross_segment = preload("res://Generation/Rooms/Scenes/cross_segment.tscn")
@onready var entrance_factory = preload("res://Generation/Rooms/Scenes/entrance_factory.tscn") 
@onready var room_factory = preload("res://Generation/Rooms/Scenes/room_factory.tscn")
@onready var boss_room = preload("res://Generation/Rooms/Scenes/boss_room.tscn")
@onready var door_front = preload("res://Generation/Rooms/Scenes/station_door_front.tscn")
@onready var door_side = preload("res://Generation/Rooms/Scenes/station_door_side.tscn")
@onready var shutter_factory = preload("res://Generation/Rooms/Scenes/shutter_factory.tscn")

@onready var boss_alpha = preload("res://Generation/Rooms/Scenes/boss_alpha.tscn")

@onready var ENEMY_SCENES: Dictionary = {
	"OBSERVER": preload("res://Scenes/enemy_observer.tscn"),
	"ALPHA_BASIC": preload("res://Scenes/enemy_alpha_basic.tscn")
}

func reset():
	is_cross_limit = false
	level_completed = false
	amount_of_rooms = 0
	rooms_cleared = 0
	robots_destroyed = 0
