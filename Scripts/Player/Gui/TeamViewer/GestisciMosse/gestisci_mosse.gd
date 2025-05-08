extends Control

var currentCharacter: CharacterData

const Move_type_color = {
	"Status":Color(0.6,0.6,0.6),
	"Fisica":Color(1,0,0),
	"Special":Color(0,1,0)
}

func Open(Character: String):
	currentCharacter = Team.CharactersData[Character]
	visible = true
	Update()
	Update_Move("")

func Update():
	$LearnableMoves/ScrollContainer/GridContainer.GenerateLearnableMoves()
	$CurrentMove/VBoxContainer.update()

func Update_Move(Selected_move: String):
	if Selected_move != "":
		$MoveInfo.visible = true
		$MoveInfo/Name.text = Selected_move
		$MoveInfo/Dscription.text = Data.Move_data[Selected_move]["Description"]
		$MoveInfo/MoveType.color = Move_type_color[Data.Move_data[Selected_move]["Move type"]]
		var Power
		if "Power" in Data.Move_data[Selected_move]:
			Power = str(Data.Move_data[Selected_move]["Power"])
		else:
			Power = "-"
		$MoveInfo/Data.text = "Type: " + Data.Move_data[Selected_move]["Type"] + "\nPotenza: " + Power + "\nPrecisione: " + str(Data.Move_data[Selected_move]["Chance"])
	else:
		$MoveInfo.visible = false


func _on_button_pressed():
	visible = false
