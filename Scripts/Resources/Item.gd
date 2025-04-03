extends Resource
class_name ItemData

@export var Name: String
@export var Category: String
@export_multiline var Description: String
@export var texture: Texture2D
@export var Heal: int = 0
@export var Energy: int = 0

func CanBeUsedInBattle() -> bool:
	return Heal > 0 or Energy > 0
