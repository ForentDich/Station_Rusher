extends Node2D

@onready var player = $Player
@onready var pauseMenu = $PauseMenu
@onready var ui = $UI
var paused = false

func _ready():
	ui._on_stop_timer()
	SceneTransistor.can_show.emit()
	Utils.save_game(Utils.current_slot)
	print(StatData.total_time,"\n", StatData.robots_destroyed,"\n" ,StatData.rooms_cleared, "\n",StatData.level_completed)
	
func _process(delta):
	if Input.is_action_just_pressed("pause"):
		pause_menu()
		

func pause_menu():
	if paused:
		pauseMenu.hide()
		get_tree().paused = false
	else:
		pauseMenu.show()
		get_tree().paused = true
		
	paused = !paused
