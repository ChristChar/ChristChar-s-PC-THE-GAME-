extends PanelContainer

var Character: CharacterData

# Called when the node enters the scene tree for the first time.


func Update():
	$HBoxContainer/Icon.texture = load("res://Resources/Images/Characters/" + Character.Character_type + "/Icon.png")
	$HBoxContainer/VBoxContainer/Name.text = Character.Character_type + " L" + str(Character.Level)
	$HBoxContainer/VBoxContainer/BarraDellaVita.max_value = Character.Calcolate_Stat("HP")
	$HBoxContainer/VBoxContainer/BarraDellaVita.value = Character.HP
