extends Control

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		visible = not visible
		Team.Pause = visible


func _on_resume_pressed():
	visible = false
	Team.Pause =  false


func _on_back_to_menu_pressed():
	get_tree().get_first_node_in_group("Game").queue_free()
	get_tree().get_first_node_in_group("Menu").visible = true
	Team.Pause =  false
