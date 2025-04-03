extends Button
class_name CharacterIcon

var character: String
var IsTeam = false

# Called when the node enters the scene tree for the first time.
func _ready():
	size = Vector2(100,100)
	custom_minimum_size = Vector2(100,100)
	tooltip_text = character
	icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon = load("res://Resources/Images/Characters/"+character+"/Icon.png")
	disabled = not character in Team.CharactersData
	connect("pressed", _on_pressed)

func _on_pressed():
	get_tree().get_first_node_in_group("TV").get_node("Info").Change_current_character(character)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	disabled = not character in Team.CharactersData

func _can_drop_data(at_position, data):
	if data in Team.CharactersData:
		if IsTeam:
			for teamate in Team.team:
				if data == teamate.Character_type:
					return false
			return true
	return false
	
func _drop_data(at_position, data):
	var Index = 0
	if character != "":
		for teamate in Team.team:
			if character == teamate.Character_type:
				break
			Index += 1
		Team.team[Index] = Team.CharactersData[data]
	else:
		Team.team.append(Team.CharactersData[data])
	character = data
	icon = load("res://Resources/Images/Characters/"+character+"/Icon.png")
	for friend in get_tree().get_nodes_in_group("Friend"):
		friend.ChangeAnimatedSprite()

func _get_drag_data(at_position:Vector2):
	if not IsTeam:
		set_drag_preview(Make_Drag_Preview(at_position))
		return character
	else:
		return null
			

func Make_Drag_Preview(at_position:Vector2):
	var t := TextureRect.new()
	t.texture = icon
	t.modulate.a = 0.6
	t.position = -at_position
	var c := Control.new()
	c.add_child(t)
	return c
