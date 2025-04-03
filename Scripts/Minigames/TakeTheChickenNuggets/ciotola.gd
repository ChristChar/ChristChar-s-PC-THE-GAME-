extends Area2D

var Score = 0

func _process(delta):
	global_position.x = lerp(global_position.x, get_global_mouse_position().x, 0.15) 
	for body in get_overlapping_bodies():
		if body is Nugget:
			Score += 1
			body.queue_free()
			
