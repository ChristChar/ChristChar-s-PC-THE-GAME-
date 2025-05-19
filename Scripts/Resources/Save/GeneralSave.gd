extends Resource
class_name Save

@export var team: Array
@export var Flags: Dictionary
@export var Inventory: Dictionary[ItemData, int]
@export var MapUnlocked: Dictionary[String, bool]
@export var InternetPoints: int = 0
@export var Quests: Dictionary[String, Dictionary] = {}
@export var CompletedQuests: Array[String] = []
