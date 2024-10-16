extends CharacterBody2D

class_name  Player

signal  points_scored(points:int)

enum PlayerMode {small, big, shooting}

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

const POINTS_LABEL = preload("res://cenas/points_label.tscn")
const SMALL_MARIO = preload("res://Resources/CollisionShapes/small_mario.tres")
const BIG_MARIO_COLLISION_SHAPE = preload("res://Resources/CollisionShapes/big_mario_collision_shape.tres")
const FIREBALL_SCENE = preload("res://cenas/fireball.tscn")


@onready var animated_sprite_2d = $AnimatedSprite2D as PlayerAnimatedSprite
@onready var area_2d = $Area2D
@onready var area_collision_shape_2d = $Area2D/AreaCollisionShape2D
@onready var body_collision_shape_2d = $BodyCollisionShape2D
@onready var shooting_point = $ShootingPoint


@export_group("Locomotion")
@export var run_speed_damping = 0.5
@export var speed = 200
@export var jump_velocity = -350
@export_group("")

@export_group("Stomping enemies")
@export var min_stomp_degree = 35
@export var max_stomp_degree = 145
@export var stomp_y_velocity = -150
@export_group("")

@export_group("Camera sync")
@export var camera_sync: Camera2D
@export var should_camera_sync: bool = true
@export_group("")

var player_mode = PlayerMode.small

var is_dead = false

var can_shoot = true  
var timer_id: Timer  

func _physics_process(delta):
	
	var camera_left_bound = camera_sync.global_position.x - camera_sync.get_viewport_rect().size.x / 2 / camera_sync.zoom.x
	
	if not is_on_floor():
		velocity.y += gravity * delta
		
	if global_position.x < camera_left_bound + 8 && sign(velocity.x) == -1: 
		velocity = Vector2.ZERO
		return 
	
	if  Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
		
	if Input.is_action_just_released("jump") and velocity.x < 0:
		velocity.x *= 0.5
	
	var direction = Input.get_axis("left", "right")
	
	if direction:
		velocity.x = lerp(velocity.x , speed * direction, run_speed_damping * delta)
	else:
		velocity.x = move_toward(velocity.x , 0 , speed * delta)
		
	if Input.is_action_just_pressed("shoot") && player_mode == PlayerMode.shooting:
		shoot()
	else:
		animated_sprite_2d.trigger_animation(velocity , direction , player_mode)
		
	var collision = get_last_slide_collision()
	if collision != null:
		handle_movement_collision(collision)
	
	move_and_slide()
	
func _process(delta):
	if global_position.x > camera_sync.global_position.x && should_camera_sync:
		camera_sync.global_position.x = global_position.x

func _on_area_2d_area_entered(area):
	if area is Enemy:
		handle_enemy_collision(area)
	if area is Shroom:
		handle_shroom_collision(area)
		area.queue_free()
	if area is ShootingFlower:
		handle_flower_collision()
		area.queue_free()
		
		
func handle_enemy_collision(enemy: Enemy):
	if enemy == null && is_dead:
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
		
func handle_shroom_collision(area: Node2D):
	if player_mode == PlayerMode.small:
		set_physics_process(false)
		animated_sprite_2d.play("small_to_big")
		set_collision_shapes(false)
		
func handle_flower_collision():
	set_physics_process(false)
	var animation_name = "small_to_shooting" if player_mode == PlayerMode.small else "big_to_shooting"
	animated_sprite_2d.play(animation_name)
	set_collision_shapes(false)
	

func spawn_points_label(enemy):
	var points_label = POINTS_LABEL.instantiate()
	points_label.position = enemy.position + Vector2(-20 , 20)
	get_tree().root.add_child(points_label)
	points_scored.emit(100)

		
func on_enemy_stomped():
	velocity.y = stomp_y_velocity
		
func die():
	if player_mode == PlayerMode.small || player_mode == PlayerMode.shooting:
		is_dead = true
		animated_sprite_2d.play("death")
		area_2d.set_collision_mask_value(3 , false)
		set_collision_layer_value(1 , false)
		set_physics_process(false)
		
		var death_tween = get_tree().create_tween()
		death_tween.tween_property(self ,"position" , position + Vector2(0 , -48) , .5)
		death_tween.chain().tween_property(self ,"position" , position + Vector2(0 , 500) , 1)
		death_tween.tween_callback(func (): get_tree().reload_current_scene())
	
	else:
		big_to_small()
	
	
func handle_movement_collision(collision: KinematicCollision2D):
	if collision.get_collider() is Block:
		var collision_angle = rad_to_deg(collision.get_angle())
		if roundf(collision_angle) == 180:
			(collision.get_collider() as Block).bump(player_mode)

func set_collision_shapes(is_small: bool):
	var collision_shape = SMALL_MARIO if is_small else BIG_MARIO_COLLISION_SHAPE
	area_collision_shape_2d.set_deferred("shape" , collision_shape)
	body_collision_shape_2d.set_deferred("shape" , collision_shape)

func big_to_small():
	set_collision_layer_value(1 , false)
	set_physics_process(false)
	var animation_name = "small_to_big" if player_mode == PlayerMode.big else "small_to_shooting"
	animated_sprite_2d.play(animation_name , 1.0 , true)
	set_collision_shapes(true)
	
func shoot():
	if can_shoot:
		animated_sprite_2d.play("shoot")
		set_physics_process(false)
		
		var fireball = FIREBALL_SCENE.instantiate()
		fireball.direction = sign(animated_sprite_2d.scale.x)
		fireball.global_position = shooting_point.global_position
		get_tree().root.add_child(fireball)	
		
		can_shoot = false
		
		$Timer.start()


func _on_timer_timeout():
	can_shoot = true
