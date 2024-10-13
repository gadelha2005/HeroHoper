extends StaticBody2D

class_name  Pipe

const top_pipe_height = 16

@export var height = 32
@export var is_traversable = false

@onready var collision_shape_2d = $CollisionShape2D
@onready var pipe_body = $PipeBody

func _ready():
	var region_rect = Rect2(pipe_body.region_rect)
	region_rect.size = Vector2(32 , height - top_pipe_height)
	pipe_body.region_rect = region_rect
	pipe_body.position = Vector2(0 , height / 2)
	
	var shape = RectangleShape2D.new()
	shape.size = Vector2(32 , height)
	collision_shape_2d.shape = shape
	collision_shape_2d.position = Vector2(0 , height / 2 - top_pipe_height / 2)
