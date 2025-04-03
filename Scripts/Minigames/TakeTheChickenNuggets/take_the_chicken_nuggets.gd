extends CanvasLayer

signal GameFinished(Score:int)

func _on_timer_timeout():
	GameFinished.emit($Ciotola.Score)
	queue_free()

func _process(delta):
	$Score.text = str($Ciotola.Score)
	

func _on_nugget_spawn_timeout():
	var NewNugget = Nugget.new()
	NewNugget.global_position.x = randi_range(0,1920)
	add_child(NewNugget)
