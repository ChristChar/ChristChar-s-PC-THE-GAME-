extends Panel

var Current_character: String = "ChristChar"
var Selected_move = ""

const Move_type_color = {
	"Status":Color(0.6,0.6,0.6),
	"Fisica":Color(1,0,0),
	"Special":Color(0,1,0)
}
# Called when the node enters the scene tree for the first time.
func _ready():
	Selected_move = Team.team[0].Current_Moves[0]
	Update()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	Update_Move()

func Change_current_character(character:String):
	Current_character = character
	Selected_move = Team.CharactersData[character].Current_Moves[0]
	Update_Move()
	Update()

func Update_Move():
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

func Update():
	if Current_character != "":
		visible = true
		var data: CharacterData = Team.CharactersData[Current_character]
		$Name.text = Current_character + " L" + str(data.Level)
		if OS.has_feature("editor"):
			var NewFrames = SpriteFrames.new()
			var Path = "res://Resources/Images/Characters/" + data.Character_type + "/Idle"
			NewFrames.add_animation("Idle")
			for Frame in File.get_files_in_directory(Path):
				if Frame.get_extension() == "png":
					NewFrames.add_frame("Idle", load(Path + "/" + Frame))
			if data.Character_type in Data.Specific_Animations and "Idle" in Data.Specific_Animations[data.Character_type]:
				if "Framerate" in Data.Specific_Animations[data.Character_type]["Idle"]:
					NewFrames.set_animation_speed("Idle", Data.Specific_Animations[data.Character_type]["Idle"]["Framerate"])
			$AnimatedSprite2D.sprite_frames = NewFrames
		else:
			$AnimatedSprite2D.sprite_frames = load("res://Data/CharacterInBattleSpriteFrames/" + data.Character_type + ".tres")
		$AnimatedSprite2D.play("Idle")
		var InfoText = "Types: "
		var Index = 0
		for Type in Data.Character_Data[data.Character_type]["Types"]:
			InfoText += Type
			if not Index ==  Data.Character_Data[data.Character_type]["Types"].size() - 1:
				InfoText += "/"
			Index += 1
		$Info.text = InfoText
		var Stats = data.Calcolate_Stats()
		for Stat in Stats:
			$Stats.get_node(Stat + "/Label").text = str(Stats[Stat])
		for child in $Buttons.get_children():
			child.queue_free()
		Index = 0
		for Move in data.Current_Moves:
			var NewButton = MoveButton.new()
			NewButton.position.y = 50 * Index
			NewButton.text = Move
			NewButton.InMenu = true
			$Buttons.add_child(NewButton)
			Index += 1
		$Exp.max_value = data.Get_Level_Up_EXP()
		$Exp.value = data.EXP
		$HP.max_value = data.Calcolate_Stat("HP")
		$HP.value = data.HP
	else:
		visible = false
