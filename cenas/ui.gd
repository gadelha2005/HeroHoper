extends CanvasLayer

class_name UI

@onready var center_container = $MarginContainer/CenterContainer


@onready var points_label = $MarginContainer/HBoxContainer/PointsLabel
@onready var coins_label = $MarginContainer/HBoxContainer/CoinsLabel

func set_score(points: int):
	points_label.text = "POINTS: %d" % points

func set_coins(coins: int):
	coins_label = "COINS: %d" % coins
	
func on_finish():
	center_container = true
