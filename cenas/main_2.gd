extends Node




func _on_passar_fase_body_entered(body):
	if (body is Player):
		get_tree().change_scene_to_file("res://cenas/win_scene.tscn")
