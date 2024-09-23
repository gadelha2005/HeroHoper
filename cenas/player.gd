extends CharacterBody2D

class_name  Player

enum PlayerMode {small, big, shooting}

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var animated_sprite_2d = $AnimatedSprite2D as PlayerAnimatedSprite
@onready var area_collision_shape_2d = $Area2D/AreaCollisionShape2D
@onready var body_collision_shape_2d = $BodyCollisionShape2D

@export_group("Locomotion")
@export var run_speed_damping = 0.5
@export var speed = 400
@export var jump_velocity = -350

var player_mode = PlayerMode.small

func _process(delta):
	
	if not is_on_floor():
		velocity.y += gravity * delta
		
	if  Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
		
	if Input.is_action_just_released("jump") and velocity.x < 0:
		velocity.x *= 0.5
	
	var direction = Input.get_axis("left", "right")
	
	if direction:
		velocity.x = lerp(velocity.x , speed * direction, run_speed_damping * delta)
	else:
		velocity.x = move_toward(velocity.x , 0 , speed * delta)
	
	animated_sprite_2d.trigger_anmation(velocity , direction , player_mode)
	
	move_and_slide()
	
