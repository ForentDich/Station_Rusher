extends CanvasLayer
class_name UI

const INVENTORY_ITEM_SCENE: PackedScene = preload("res://Interface/InventoryItem.tscn")
const MIN_HEALTH: int = 4

signal timer_can_start
signal dad

var max_hp : int = 8
var is_droped: bool = false;

var time = 0;
var timer_on = false;

var rooms_left = 99;

@onready var player : CharacterBody2D = get_tree().get_first_node_in_group("Player")
var playerHealthComponent

@onready var heartsContainer : HBoxContainer = get_node("HeartsContainer")
@onready var labelAdvice : Label = get_node("LabelAdvice")
@onready var inventoryBar : Control = get_node("InventoryBar")
@onready var labelAmmo : Label = get_node("Ammo/LabelAmmo")
@onready var timer : Control = get_node("Timer")
@onready var labelTimer : Label = get_node("Timer/HBoxContainer/Control2/LabelTimer")
@onready var rooms : Control = get_node("Rooms")
@onready var labelRooms : Label = get_node("Rooms/LabelRooms")
@onready var labelReturn : Label = get_node("ReturnLabel")

func _ready() -> void:
	
	player.connect("weapon_switched", _on_player_weapon_switched)
	player.connect("weapon_picked_up", _on_player_weapon_picked_up)
	player.connect("weapon_droped", _on_player_weapon_droped)
	timer_can_start.connect(_on_start_timer)
	
	playerHealthComponent = player.find_child("HealthComponent")
	max_hp = playerHealthComponent.max_health
	heartsContainer.set_max_hearts(max_hp)
	heartsContainer.update_hearts(max_hp)
	
	playerHealthComponent.hp_changed.connect(heartsContainer.update_hearts)
	playerHealthComponent.player_dead.connect(_on_stop_timer)


func return_timer():
	var sec : int = 10
	labelReturn.text = "Возвращение через %d" % [sec]
	await get_tree().create_timer(3).timeout
	labelReturn.show()

	while sec > 0:
		await get_tree().create_timer(1).timeout
		sec -= 1
		labelReturn.text = "Возвращение через %d" % [sec]
	labelReturn.hide()

func _on_start_timer():
	timer_on = true
	rooms_left = GlobalGeneration.amount_of_rooms
	
func _on_stop_timer():
	timer_on = false
	time = 0
	timer.hide()
	rooms.hide()

func _process(delta):
	var str_ammo_capacity : String = str(SavedData.ammo_capacity)
	if SavedData.ammo_capacity > 10000:
		str_ammo_capacity = "∞"
		
	labelAmmo.text = (str(SavedData.current_ammo) + "/" + str_ammo_capacity)
	
	if (timer_on):
		time += delta
	
	var secs = fmod(time, 60)
	var mins = fmod(time, 60*60) / 60
	var time_passed = "%d:%02d" % [mins, secs]
	labelTimer.text = time_passed
	
	labelRooms.text = "Комнат: %d/%d" % [rooms_left - GlobalGeneration.amount_of_rooms, rooms_left]

func _on_player_weapon_switched(prev_index, new_index):
	if inventoryBar.get_child(1).get_child(0).get_child_count() == 0 and inventoryBar.get_child(2).get_child(0).get_child_count() == 0:
		return
	
	var index = SavedData.equipped_weapon_index
	var base_array : Array
	
	for i in range(SavedData.weapons.size()):
		base_array.push_back(i)
	
	if index == 3:
		return
	
	base_array = base_array.slice(index) + base_array.slice(0, index)

	for i in inventoryBar.get_children():
		if i.get_child(0).get_child_count() != 0:
			i.get_child(0).get_child(0).queue_free()
	
	for j in range(SavedData.weapons.size()):
		var new_inventory_item: TextureRect = INVENTORY_ITEM_SCENE.instantiate()
		inventoryBar.get_child(j).get_child(0).add_child(new_inventory_item)
		new_inventory_item.initialize(SavedData.weapons[base_array[j]].get_texture())

func _on_player_weapon_picked_up(weapon_texture):
	var new_inventory_item: TextureRect = INVENTORY_ITEM_SCENE.instantiate()
	if is_droped:
		inventoryBar.get_child(0).get_child(0).add_child(new_inventory_item)
		new_inventory_item.initialize(weapon_texture)
		is_droped = false
		
	for i in inventoryBar.get_children():
		if i.get_child(0).get_child_count() == 0:
			i.get_child(0).add_child(new_inventory_item)
			new_inventory_item.initialize(weapon_texture)
			break


func _on_player_weapon_droped(index):
	for i in inventoryBar.get_child(0).get_child(0).get_children():
		inventoryBar.get_child(0).get_child(0).remove_child(i)
		i.queue_free()
	is_droped = true

func reset_ui():
	for i in inventoryBar.get_child(0).get_child(0).get_children():
		inventoryBar.get_child(0).get_child(0).remove_child(i)
		i.queue_free()
