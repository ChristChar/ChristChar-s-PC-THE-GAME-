extends GridContainer

func GenerateLearnableMoves():
	for child in get_children():
		child.queue_free()
	var data: CharacterData = %GestisciMosse.currentCharacter
	for move in data.Learnable_Moves:
		if not move in data.Current_Moves:
			var NewButton := LearnableMoveButton.new()
			NewButton.Move = move
			add_child(NewButton)
