extends CanvasLayer

@onready var animationPlayer: AnimationPlayer = $AnimationPlayer
@onready var screen: Control = $Screen

signal can_show

var current_scene = null

func _ready() -> void:
	screen.mouse_filter = 2
	can_show.connect(_show_scene)
	var root = get_tree().root
	current_scene = root.get_child(root.get_child_count() - 1)

func switch_scene(res_path):
	call_deferred("_deffered_switch_scene", res_path)
	
func _deffered_switch_scene(res_path):
	screen.mouse_filter = 0
	animationPlayer.play("dissolve")
	await animationPlayer.animation_finished
	current_scene.free()
	var s = load(res_path)
	current_scene = s.instantiate()
	get_tree().root.add_child(current_scene)
	get_tree().current_scene = current_scene

func _show_scene():
	animationPlayer.play_backwards("dissolve")
	screen.mouse_filter = 2
