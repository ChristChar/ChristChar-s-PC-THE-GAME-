extends Button
class_name  LearnableMoveButton

var Move: String
var IsCurrentMove = false

func _ready():
	custom_minimum_size = Vector2(100, 100)
	text = Move
	
	if Move == "None":
		disabled = true
		return
	# Ottieni il colore dal file dei dati
	var Style = load("res://Data/Resources/TypesStyle/" + Data.Move_data[Move]["Type"] + ".tres")
	var bg_color: Color
	if Style is StyleBoxFlat:
		bg_color = Style.bg_color
	else:
		bg_color = Color(1,1,1)
	
	
	# Determina il colore del testo in base alla luminosità dello sfondo
	var text_color: Color
	if File.is_closer_to_white(bg_color):
		text_color = Color(0, 0, 0)  # Nero
	else:
		text_color = Color(1, 1, 1)  # Bianco
	
	# Applica i colori al tema
	add_theme_color_override("font_color", text_color)
	add_theme_color_override("font_focus_color", text_color)
	
	# Crea uno stylebox con lo sfondo colorato
	add_theme_stylebox_override("normal", Style)


	
func _pressed():
	var GestisciMosse
	if IsCurrentMove:
		GestisciMosse = $"../../.."
	else:
		GestisciMosse = $"../../../.."
	GestisciMosse.Update_Move(Move)

func Make_Drag_Preview(at_position:Vector2):
	var t = Label.new()
	t.text = Move
	t.modulate.a = 0.6
	t.position = -at_position
	var c := Control.new()
	c.add_child(t)
	return c

func _get_drag_data(at_position:Vector2):
	if not IsCurrentMove:
		set_drag_preview(Make_Drag_Preview(at_position))
		return Move
	else:
		return null

func _can_drop_data(at_position, data):
	if IsCurrentMove:
		return true
	return false

func _drop_data(at_position, data):
	var Character:CharacterData = $"../../..".currentCharacter
	if Move != "None":
		Character.Current_Moves.erase(Move)
	Character.Current_Moves.append(data)
	Move = data
	_ready()
	$"../../..".Update()
