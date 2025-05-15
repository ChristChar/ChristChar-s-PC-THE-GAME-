extends Control

var SelectedMap: MapData

var GameScene = preload("res://Scenes/Game.tscn")

func _ready():
	UpdateInfos()

func ChangeSelecedMap(NewData:MapData):
	if SelectedMap == NewData:
		SelectedMap = null
	else:
		SelectedMap = NewData
	UpdateInfos()

func UpdateInfos():
	if SelectedMap:
		$Infos.visible = true
		$Infos/Preview/SubViewport/Sprite2D.texture = SelectedMap.Preview
		$Infos/Name.text = SelectedMap.Name
		$Infos/Description.text = SelectedMap.Description
		var CharacterObtained = 0
		for Flag in SelectedMap.CharactersToFindFlags:
			if Flag in Team.Flags and Team.Flags[Flag]:
				CharacterObtained += 1
		$Infos/Infos.text = str(CharacterObtained) + "/" + str(SelectedMap.CharactersToFindFlags.size())
	else:
		$Infos.visible = false



func _on_start_pressed():
	var Game = GameScene.instantiate()
	Game.data = SelectedMap
	Team.Game = Game
	get_tree().root.add_child(Game)
	get_parent().visible = false
	Team.EnterInMap.emit(SelectedMap.Name)
