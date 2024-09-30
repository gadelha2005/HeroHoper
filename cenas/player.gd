extends CharacterBody2D

class_name  Player

signal  points_scored(points:int)

enum PlayerMode {small, big, shooting}

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

const POINTS_LABEL = preload("res://cenas/points_label.tscn")

@onready var animated_sprite_2d = $AnimatedSprite2D as PlayerAnimatedSprite
@onready var area_collision_shape_2d = $Area2D/AreaCollisionShape2D
@onready var body_collision_shape_2d = $BodyCollisionShape2D

@export_group("Locomotion")
@export var run_speed_damping = 0.5
@export var speed = 400
@export var jump_velocity = -350
@export_group("")

@export_group("Stomping enemies")
@export var min_stomp_degree = 35
@export var max_stomp_degree = 145
@export var stonp_y_velocity = -150
@export_group("")



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
	


func _on_area_2d_area_entered(area):
	if area is Enemy:
		handle_enemy_collision(area)
		
func handle_enemy_collision(enemy: Enemy):
	if enemy == null:
		return 
		
	if is_instance_of(enemy , Koppa) and (enemy as Koppa).in_a_shell:
		(enemy as Koppa).on_stomp(global_position)
	else:
		var angle_of_collision = rad_to_deg(position.angle_to_point(enemy.position))
		
		if angle_of_collision > min_stomp_degree && max_stomp_degree > angle_of_collision:
			enemy.die()
			on_enemy_stomped()
			spawn_points_label(enemy)
		else:
			die()
		

func spawn_points_label(enemy):
	var points_label = POINTS_LABEL.instantiate()
	points_label.position = enemy.position + Vector2(-20 , 20)
	get_tree().root.add_child(points_label)
	points_scored.emit(100)

		
func on_enemy_stomped():
	velocity.y = stonp_y_velocity
		
func die():
	print("Die")
	
