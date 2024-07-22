extends Node

enum STATES {IDLE, MOVE}
var state: int = 0

@onready var parent = get_parent()

func _process(delta) -> void:
	run_state(delta)
	
func run_state(delta) -> void:
	parent.aim(parent.get_global_mouse_position())
	parent.get_input()
	parent.move(delta)
	
	match state:
		STATES.IDLE:
			if(parent.input_vector != Vector2.ZERO):
				set_state(STATES.MOVE)

		STATES.MOVE:
			parent.animate_legs()
			if (parent.input_vector == Vector2.ZERO):
				set_state(STATES.IDLE)

func set_state(new_state: int):
	if (state == new_state):
		return
	
	state = new_state
	
