extends StaticBody2D

@export var path : String
@export var action_name : String

@onready var interactionArea = $InteractionArea

func _ready():
	interactionArea.action_name = action_name
	interactionArea.interact = Callable(self, "_switch_scene")
	

func _switch_scene():
	SceneTransistor.switch_scene(path)
	SavedData.reset_data()
