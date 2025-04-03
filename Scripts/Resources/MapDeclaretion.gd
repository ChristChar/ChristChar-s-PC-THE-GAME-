extends Resource
class_name MapData

@export var Name: String
@export_multiline var Description: String
@export var Unlock: bool = false
@export var Scene: PackedScene
@export var Preview: Texture2D
@export var Icon: Texture2D

@export_subgroup("Data")
@export var CharactersToFindFlags: Array[String] = []
