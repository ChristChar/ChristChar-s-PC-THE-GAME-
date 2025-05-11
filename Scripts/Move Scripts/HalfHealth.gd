extends Node

var Has_Target = true

func script(User:CharacterData,Target:CharacterData,Move:String,Index: int):
	Target.Take_damage(round(Target.HP * 0.5))
