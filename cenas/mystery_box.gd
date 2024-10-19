extends Block

class_name  MysteryBox

enum  BonusType {
	coin , 
	shroom,
	flower
}

const coin_scene = preload("res://cenas/coin.tscn")
const shroom_scene = preload("res://cenas/shroom.tscn")
const shooting_flower_scene = preload("res://cenas/shooting_flower.tscn")

@onready var animated_sprite_2d = $AnimatedSprite2D
@export var bonus_type: BonusType = BonusType.coin
@export var invisible:bool = false
var is_empty = false

func _ready():
	animated_sprite_2d.visible = !invisible
	
func bump(player_mode: Player.PlayerMode):
	if is_empty:
		return 
		
	if invisible:
		animated_sprite_2d = true
		invisible = !invisible
		
	super.bump(player_mode)
	make_empty()
	
	match bonus_type:
		BonusType.coin:
			spawn_coin()
		BonusType.shroom:
			spawn_shroom()
		BonusType.flower:
			spawn_flower()

func make_empty():
	is_empty = true
	animated_sprite_2d.play("empty")
	
func spawn_shroom():
	var shroom = shroom_scene.instantiate()
	shroom.global_position = global_position
	get_tree().root.add_child(shroom)

func spawn_coin():
	var coin = coin_scene.instantiate()
	coin.global_position = global_position + Vector2(0 , -16)
	get_tree().root.add_child(coin)
	

func spawn_flower():
	var flower = shooting_flower_scene.instantiate()
	flower.global_position = global_position
	get_tree().root.add_child(flower)
