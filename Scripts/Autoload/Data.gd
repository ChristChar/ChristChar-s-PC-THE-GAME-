extends Node

var Character_Data: Dictionary
var Move_data: Dictionary
var Type_data: Dictionary
var Specific_Animations: Dictionary
# Called when the node enters the scene tree for the first time.
func _ready():
	Character_Data = File.Read_json("res://Data/Json/Personaggi.json")
	Move_data = File.Read_json("res://Data/Json/Move.json")
	Type_data = File.Read_json("res://Data/Json/Types.json")
	Specific_Animations = File.Read_json("res://Data/Json/SpecificAnimations.json")
