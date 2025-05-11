extends Button
class_name MoveButton

var InMenu = false

# Called when the node enters the scene tree for the first time.
func _ready():
	size = Vector2(200, 50)
	connect("pressed", _on_move_button)
	z_index = 10
	if text != "Skip":
		var Style = load("res://Data/Resources/TypesStyle/" + Data.Move_data[text]["Type"] + ".tres")
		var bg_color: Color
		if Style is StyleBoxFlat:
			bg_color = Style.bg_color
		else:
			bg_color = Color(1,1,1)
		add_theme_stylebox_override("normal", Style)
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
	if InMenu:
		get_parent().get_parent().Selected_move = text
	else:
		get_parent().get_parent().get_parent().Selected_move = text
