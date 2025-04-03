extends Area3D

var dialogo_mostrato = false

func _process(delta):
	if Team.Pause:
		return
	if dialogo_mostrato: # Aggiunta
		return
	for body in get_overlapping_bodies():
		if body is Player:
			dialogo_mostrato = true # Imposta la variabile
			DialogueManager.show_dialogue_balloon(preload("res://Data/Dialogue/TurnBackInMainMap.dialogue"), "start")
			Team.Pause = true
			await DialogueManager.dialogue_ended
			Team.Pause = false
			body.global_position.z -= 2
			await get_tree().create_timer(1).timeout
			dialogo_mostrato = false # Reset della variabile dopo il dialogo
			return # Aggiunta per evitare ulteriori iterazioni
