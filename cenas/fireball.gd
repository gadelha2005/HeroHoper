extends Area2D

class_name  Fireball

@onready var ray_cast_2d = $RayCast2D
@export var horizontal_speed = 200
@export var vertical_speed = 100
@export var fire_rate = 5.0

var amplitude = 20
var is_moving_up = false
var direction 
var vertical_movement_start_position
var fire_timer = 0.0

func _process(delta):
	
	fire_timer += delta
	
	if fire_timer >= fire_rate:
		fire_timer -= fire_rate
		var new_fireball = preload("res://cenas/fireball.tscn").instantiate()
		get_parent().add_child(new_fireball)
		new_fireball.position = position
		new_fireball.direction = direction
		fire_timer = 0.0

	
	position.x += delta * horizontal_speed * direction
	if ray_cast_2d.is_colliding():
		is_moving_up = true
		vertical_movement_start_position = position
		
	if is_moving_up:
		position.y -= vertical_speed * delta
		if vertical_movement_start_position.y - amplitude >= position.y:
			is_moving_up = false
	if !is_moving_up:
		position.y += delta * vertical_speed


func _on_area_entered(area):
	if (area is Enemy):
		area.die_from_hit()
		queue_free()


func _on_body_entered(body):
	queue_free()
