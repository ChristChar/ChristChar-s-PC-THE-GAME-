extends VBoxContainer


func update():
	for child in get_children():
		child.queue_free()
	var character: CharacterData = %GestisciMosse.currentCharacter
	for move in character.Current_Moves:
		var NewButton = LearnableMoveButton.new()
		NewButton.IsCurrentMove = true
		NewButton.Move = move
		add_child(NewButton)
	for i in range(4 - character.Current_Moves.size()):
		var NewButton = LearnableMoveButton.new()
		NewButton.IsCurrentMove = true
		NewButton.Move = "None"
		add_child(NewButton)
