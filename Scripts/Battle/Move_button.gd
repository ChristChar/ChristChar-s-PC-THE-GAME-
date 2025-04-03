extends Button
class_name MoveButton

# Called when the node enters the scene tree for the first time.
func _ready():
	size = Vector2(200, 50)
	connect("pressed", _on_move_button)
	z_index = 10
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_move_button():
	get_parent().get_parent().Selected_move = text
