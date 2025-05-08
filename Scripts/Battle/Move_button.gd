extends Button
class_name MoveButton

# Called when the node enters the scene tree for the first time.
func _ready():
	size = Vector2(200, 50)
	connect("pressed", _on_move_button)
	z_index = 10
	if text != "Skip":
		var bg_color = File.RGB_to_color(Data.Type_data[Data.Move_data[text]["Type"]]["Color"])
		var stylebox = StyleBoxFlat.new()
		stylebox.bg_color = bg_color
		add_theme_stylebox_override("normal", stylebox)
		var color: Color
		if File.is_closer_to_white(bg_color):
			color = Color(0,0,0)
		else:
			color = Color(1,1,1)
		add_theme_color_override("font_color", color)
		add_theme_color_override("font_focus_color", color)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_move_button():
	get_parent().get_parent().Selected_move = text
