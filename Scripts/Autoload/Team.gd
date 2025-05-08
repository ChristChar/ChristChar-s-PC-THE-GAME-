@tool
extends Node

var Flags = {}
var team: Array[CharacterData] = []
var CharactersData: Dictionary[String, CharacterData] = {}
var Pause = false
var Is_in_battle = false
var LastBattleResult = true
var Maps
var Inventory: Dictionary[ItemData, int] = {}
var LastTalker: Node3D

const animations = ["Idle","Dead","Fail", "Dying", "Nap"]
const BattlePath = "res://Scenes/battagllia.tscn"

signal FinishedBattle()

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


func CheckSaveDir():
	var dir_path = "user://Saves"
	var dir = DirAccess.open(dir_path)
	if not dir:
		var User = DirAccess.open("user://")
		User.make_dir_recursive("user://Saves/Characters")
		return true
	return false

func _exit_tree():
	SaveData()

# Called when the node enters the scene tree for the first time.
func _ready():
	Inventory[preload("res://Data/Resources/Items/Mela.tres")] = 2
	randomize()
	CharactersData["Bob"] =  CharacterData.new("Bob", 10)
	CharactersData["ChristChar"] =  CharacterData.new("ChristChar", 10)
	CharactersData["Pixy"] =  CharacterData.new("Pixy", 16)
	team = [CharactersData["ChristChar"], CharactersData["Bob"]]
	LoadData()

func ObtainCharacter(Character:String):
	var player: Player = get_tree().get_first_node_in_group("Player")
	player.ViewObtainedCharacter(Character)
	CharactersData[Character] = CharacterData.new(Character, 10)

func DestroyTalker():
	LastTalker.queue_free()

func Cure_team():
	for teamate in team:
		teamate.Reset()

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
		var NewEnemy = CharacterData.new(Enemy["Type"], Enemy["Level"])
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
	get_tree().root.add_child(Battle)
	await Battle.Finish_Battle
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
