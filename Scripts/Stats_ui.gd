extends CanvasLayer

@onready var labelStat = $Panel/VBoxContainer/LabelStat
@onready var labelStat2 = $Panel/VBoxContainer/LabelStat2
@onready var labelStat3 = $Panel/VBoxContainer/LabelStat3
@onready var labelStat4 = $Panel/VBoxContainer/LabelStat4
@onready var labelStat5 = $Panel/VBoxContainer/LabelStat5

func _on_texture_button_pressed():
	hide()

func _ready():
	var time = StatData.total_time
	var secs = fmod(time, 60)
	var mins = fmod(time, 60*60) / 60
	
	labelStat.text = "Пройдено станций: %d" % [StatData.level_completed]
	labelStat2.text = "Зачищено комнат: %d" % [StatData.rooms_cleared]
	labelStat3.text = "Ликвидировано врагов: %d" % [StatData.robots_destroyed]
	labelStat4.text = "Время на станциях: %d:%02d" % [mins, secs]
	labelStat5.text = "Игрок погиб: %d" % [StatData.player_deaths]
