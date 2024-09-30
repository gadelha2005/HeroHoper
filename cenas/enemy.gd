extends Area2D


class_name Enemy

const POINTS_LABEL = preload("res://cenas/points_label.tscn")

@export var horizontal_speed = 20
@export var vertical_speed = 100

@onready var ray_cast_2d = $RayCast2D as RayCast2D
@onready var animated_sprite_2d = $AnimatedSprite2D as AnimatedSprite2D

func _process(delta):
	position.x -= horizontal_speed * delta

	if !ray_cast_2d.is_colliding():
		position.y += vertical_speed * delta


func die():
	horizontal_speed = 0
	vertical_speed = 0 
	animated_sprite_2d.play("dead")


func die_from_hit():
	set_collision_layer_value(3 , false)
	set_collision_mask_value(3 , false)
	
	rotation_degrees = 180
	horizontal_speed = 0 
	vertical_speed = 0
	
	var die_tween = get_tree().create_tween()
	die_tween.tween_property(self , "position" , position + Vector2(0 , -25) , .2) 
	die_tween.tween_property(self , "position" , position + Vector2(0 , 500) , 4)
	
	var points_label =  POINTS_LABEL.instantiate()
	points_label.position = self.position + Vector2(-20 , -20)
	
	
func _on_area_entered(area):
	if area is Koppa and (area as  Koppa).in_a_shell and (area as Koppa).horizontal_speed != 0 : 
		die_from_hit()
		

