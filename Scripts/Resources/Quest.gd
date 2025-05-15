extends Resource
class_name Quest

@export var Name: String
@export var ID: String
@export_multiline var Description: String
@export var Objectives: Dictionary[String, int] = {}
@export var MapLocation: String
@export var CordLocation: Vector2
@export_enum("Primary", "Secondary") var Type: String = "Primary"
var Progress: Dictionary[String, int]
var Complete = false

signal complete(Name: String)

func Add_progress(ID:String):
	if Complete:
		return
	if ID in Objectives:
		Progress[ID] += 1
		if CheckComplete():
			Complete = true
			complete.emit(Name)

func CheckComplete() -> bool:
	for Key in Progress:
		if not Progress[Key] >= Objectives[Key]:
			return false
	return true

func _init():
	for Key in Objectives.keys():
		Progress[Key] = 0
