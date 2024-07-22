extends StaticBody2D


@onready var interactionArea = $InteractionArea
@onready var ui_stat = get_node("/root/Ship/Stats")

func _ready():
	interactionArea.interact = Callable(self, "show_stat")

func show_stat():
	ui_stat.show()


func _on_interaction_area_body_exited(body):
	ui_stat.hide()
