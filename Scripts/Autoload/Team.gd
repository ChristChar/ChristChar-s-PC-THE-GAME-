extends Node

var IPoints: int = 0
var LevCap: int = 20
var LoadingValue = 100
var team: Array[CharacterData] = []
var Flags = {}
var CharactersData: Dictionary[String, CharacterData] = {}
var Pause = false
var Is_in_battle = false
var LastBattleResult = true
var Maps
var Inventory: Dictionary[ItemData, int] = {}
var Quests: Dictionary[String, Quest] = {}
var CompletedQuests: Array[String] = []
var LastTalker: Node3D
var Game: Node3D
var Notifics := VBoxContainer.new()
var MapsData = [
	preload(MapPath + "ChristChar's PC.tres"),
	preload(MapPath + "Pixy's PC.tres"),
	preload(MapPath + "Internet.tres"),
	preload(MapPath + "Inkerbot's PC.tres")
]

const animations = ["Idle","Dead","Fail", "Dying", "Nap"]
const BattlePath = "res://Scenes/battagllia.tscn"
const MapPath = "res://Data/Resources/Maps/"

signal FinishedBattle()
signal EnterInMap(map:String)

func SaveData():
	CheckSaveDir()
	const path = "user://Saves/Characters/"
	for teamate in CharactersData:
		ResourceSaver.save(CharactersData[teamate].GenerateSave(), path + teamate + ".tres")
	var NewSave = Save.new()
	for teamate in team:
		NewSave.team.append(teamate.Character_type)
	NewSave.Flags = Flags
	NewSave.Inventory = Inventory
	for map: MapData in MapsData:
		NewSave.MapUnlocked[map.Name] = map.Unlock
	NewSave.InternetPoints = IPoints
	for quest: Quest in Quests.values():
		NewSave.Quests[quest.ID] = quest.Progress
	NewSave.CompletedQuests = CompletedQuests
	ResourceSaver.save(NewSave, "user://Saves/Save.tres")

func LoadData():
	if CheckSaveDir():
		return
	for Character: String in File.get_files_in_directory("user://Saves/Characters/"):
		CharactersData[Character.trim_suffix(".tres")] = CharacterData.new(load("user://Saves/Characters/" + Character))
	var save: Save = load("user://Saves/Save.tres")
	if save:
		team = []
		for teamate in save.team:
			team.append(CharactersData[teamate])
		Flags = save.Flags
		Inventory = save.Inventory
		for map: MapData in MapsData:
			if map.Name in save.MapUnlocked:
				map.Unlock = save.MapUnlocked[map.Name] 
		IPoints = save.InternetPoints
		for quest in save.Quests:
			var NewQuest = GetQuest(quest)
			NewQuest.Progress = save.Quests[quest]
			Quests[quest] = NewQuest
		CompletedQuests = save.CompletedQuests

func AddQuestProgress(ID:String):
	for quest in Quests.values():
		quest.Add_progress(ID)

func AddQuest(quest, Notific: bool = true):
	var NewQuest: Quest
	if quest is Quest:
		NewQuest = quest
	else:
		NewQuest = load(quest)
	NewQuest._init()
	if NewQuest.ID in Quests:
		return
	Quests[NewQuest.ID] = NewQuest
	NewQuest.complete.connect(OnQuestComplete)
	if Notific:
		AddNotific("New quest: " + NewQuest.Name + "!", preload("res://Resources/Images/Icone/Quest.png"))

func AddNotific(Text: String, texture: Texture2D = null):
	var NewNotific = preload("res://Scenes/Gui/Notific.tscn").instantiate()
	NewNotific.text = Text
	if texture:
		NewNotific.texture = texture
	Notifics.add_child(NewNotific)

func AddLevCap(Qtd: int, Notific:bool = true):
	LevCap += Qtd
	if Notific:
		AddNotific("+" + str(Qtd) + " Level Cap!!!")

func CheckSaveDir():
	var dir_path = "user://Saves"
	var dir = DirAccess.open(dir_path)
	if not dir:
		var User = DirAccess.open("user://")
		User.make_dir_recursive("user://Saves/Characters")
		return true
	return false

func GetQuest(ID: String) -> Quest:
	return load("res://Data/Resources/Quests/" + ID + ".tres")

func _exit_tree():
	SaveData()

func OnQuestComplete(quest: Quest):
	AddNotific("Quest completed: " + quest.Name, preload("res://Resources/Images/Icone/Quest.png"))
	for reward in quest.Reward:
		match reward:
			"IPoints":
				AddIPoints(quest.Reward[reward])
			"NewQuest":
				AddQuest(load(quest.Reward[reward]), false)
			"Map":
				UnlockMap(quest.Reward[reward])
	CompletedQuests.append(quest.ID)
	Quests.erase(quest.ID)
				

func AddIPoints(Qtd:int, Notific: bool = true):
	IPoints += Qtd
	if Notific:
		var n = ""
		if Qtd > 1:
			n += "+"
		AddNotific(n + str(Qtd) + " IPoints", preload("res://Resources/Images/Icone/IPoints.png"))

func RemoveIPoints(Qtd:int, Notific: bool = true):
	if IPoints >= Qtd:
		AddIPoints(-Qtd, Notific)
		return true
	return false

# Called when the node enters the scene tree for the first time.
func _ready():
	add_child(Notifics)
	Inventory[preload("res://Data/Resources/Items/Mela.tres")] = 2
	randomize()
	CharactersData["Bob"] =  CharacterData.new("Bob", 10)
	CharactersData["ChristChar"] =  CharacterData.new("ChristChar", 10)
	CharactersData["Pixy"] =  CharacterData.new("Pixy", 16)
	CharactersData["Cat"] =  CharacterData.new("Cat", 12)
	CharactersData["Chrome dino"] =  CharacterData.new("Chrome dino", 12)
	CharactersData["Windows defenders"] =  CharacterData.new("Windows defenders", 15)
	team = [CharactersData["ChristChar"]]
	LoadData()
	EnterInMap.connect(OnEnterMap)

func ObtainCharacter(Character:String):
	var player: Player = get_tree().get_first_node_in_group("Player")
	player.ViewObtainedCharacter(Character)
	CharactersData[Character] = CharacterData.new(Character, 10)

func DestroyTalker():
	LastTalker.queue_free()

func Cure_team():
	for teamate in team:
		teamate.Reset()

func UnlockMap(map:String, Notific: bool = true):
	for CurrentMap: MapData in MapsData:
		if CurrentMap.Name == map:
			if Notific:
				AddNotific("New map: " + map + "!")
			CurrentMap.Unlock = true
			return
	print("SCEMO, MAPPA NON TROVATA: ", map)

func OnEnterMap(map):
	match  map:
		"ChristChar's PC": 
			pass

func Get_max_level() -> int:
	var MaxLevel = 0
	for Character in CharactersData:
		if CharactersData[Character].Level > MaxLevel:
			MaxLevel =  CharactersData[Character].Level
	return MaxLevel

func GenerateBattleFromJSON(json:String):
	var data = File.Read_json(json)
	GenerateBattle(data)

func GenerateBattle(EnemysData:Array):
	var EnemyTeam: Array[CharacterData] = []
	for Enemy in EnemysData:
		var Boss = false
		if "Boss" in Enemy:
			Boss = Enemy["Boss"]
		var NewEnemy = CharacterData.new(Enemy["Type"], Enemy["Level"], Boss)
		if "Moves" in Enemy:
			NewEnemy.Current_Moves = Enemy["Moves"]
		EnemyTeam.append(NewEnemy)
	Team.StartBattle(EnemyTeam)

func StartBattle(Enemys:Array[CharacterData]):
	Pause = true
	Is_in_battle = true
	get_tree().get_first_node_in_group("Player").Battle_Start_Animation()
	await get_tree().get_first_node_in_group("Player").BattleAnimationFinished
	var Battle = load(BattlePath).instantiate()
	Battle.EnemyTeam = Enemys
	get_tree().root.remove_child(Game)
	get_tree().root.add_child(Battle)
	await Battle.Finish_Battle
	get_tree().root.add_child(Game)
	Battle.queue_free()
	Pause = false
	Is_in_battle = false
	FinishedBattle.emit()

func StartMiniGame(MiniGame: String):
	var Game = load(MiniGame).instantiate()
	add_child(Game)
	return Game

func _process(delta):
	if Is_in_battle:
		Pause = true
