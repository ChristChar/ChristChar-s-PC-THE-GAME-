extends AudioStreamPlayer

func _process(delta):
	if Team.Is_in_battle:
		playing = false
	elif not playing:
		playing = true
		 
