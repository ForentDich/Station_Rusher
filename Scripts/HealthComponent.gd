extends Node2D
class_name HealthComponent

signal player_dead
signal hp_changed
signal hit

@export var max_health : int = 10
var health : int = 1


func _ready():
	health = max_health
	
func damage(attack : Attack):
	health -= attack.attack_damage
	if get_parent().name != "Player":
		hit.emit()
	if get_parent().name == "Player":
		SavedData.HP = health
		if health <= 0:
			player_dead.emit()
			SceneTransistor.switch_scene("res://ship.tscn")
			GlobalGeneration.reset()
			StatData.player_deaths += 1
			SavedData.reset_data()
	
	if get_parent().name == "BossAlpha":
		if health <= 0:
			GlobalGeneration.level_completed = true
			get_parent().queue_free()
	
	if health <= 0 and get_parent().name != "Player" and get_parent().name != "BossAlpha":
		get_parent().queue_free()
		
	hp_changed.emit(health)
