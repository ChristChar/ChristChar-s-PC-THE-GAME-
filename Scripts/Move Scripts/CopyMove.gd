extends Node

var Has_Target = true

func script(User:CharacterData,Target:CharacterData,Move:String,Index: int):
	var NewMove = Target.LastMoveUsed
	var NewTarget
	match Data.Move_data[NewMove]["Target"]:
		"Self":
			NewTarget = User
		"Enemy":
			NewTarget = Target
		"All":
			if User.IsEnemy:
				NewTarget = get_tree().get_first_node_in_group("Battle").PlayerTeam
			else:
				NewTarget = get_tree().get_first_node_in_group("Battle").EnemyTeam
	if NewTarget is Array:
		for target in NewTarget:
			User.Use_Move(NewMove, target)
	else:
		User.Use_Move(NewMove, NewTarget)
