extends Block

class_name  MysteryBox

enum  BonusType {
	coin , 
	shroom,
	flower
}

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

func make_empty():
	is_empty = true
	animated_sprite_2d.play("empty")
	
