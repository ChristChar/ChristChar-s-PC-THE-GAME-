extends Node

var Has_Target = true

func script(User:CharacterData,Target:CharacterData,Move:String,Index: int):
	Target.IsEnemy = User.IsEnemy
