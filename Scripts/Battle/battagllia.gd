extends Node3D

var EnemyTeam = []
var PlayerTeam = []
var TurnOrder = []
var TurnIndex = 0
var Mause_in_battle_area = false

signal Enter()
signal Finish_Turn()
signal Finish_Battle()
signal Finished_Death_Animation()

func _ready():
	randomize()
	var map: Map = Team.Game.CurrentMap
	if map.BattleBackground:
		$Map.queue_free()
		add_child(map.BattleBackground.instantiate())
	if EnemyTeam == []:
		setup_teams()
	var Index = 0
	for personaggio in Team.team:
		var NewCharacter = personaggio
		var spawn_point: Node3D = $Spawn.get_child(Index)
		NewCharacter.global_position = spawn_point.global_position
		NewCharacter.StartPosition = spawn_point.global_position
		PlayerTeam.append(NewCharacter)
		personaggio.rotation.x = deg_to_rad(-45)
		add_child(NewCharacter)
		Index += 1

	Index = 0
	for personaggio in EnemyTeam:
		var NewCharacter: CharacterData = personaggio
		NewCharacter.global_position = $EnemySpawn.get_child(Index).global_position
		NewCharacter.IsEnemy = true
		personaggio.rotation.x = deg_to_rad(-45)
		add_child(NewCharacter)
		Index += 1
	End_round()

func setup_teams():
	var Enemys = []
	var Character_data = Data.Character_Data
	for Character in Character_data:
		if Character_data[Character]["IsEnemy"]:
			Enemys.append(Character)
	for i in range(randi_range(1, 4)):
		var newEnemy = CharacterData.new(Enemys[randi_range(0, Enemys.size() - 1)], 10)
		EnemyTeam.append(newEnemy)

func End_round():
	for battler in EnemyTeam + PlayerTeam:
		battler.EndRound()
	TurnIndex = 0
	TurnOrder = get_tree().get_nodes_in_group("Combattente")
	TurnOrder.sort_custom(func(a, b): return a.Calcolate_Stat("SPEED") > b.Calcolate_Stat("SPEED"))

func _process(delta):
	if not Giving_exp:
		Turn()
	Wait_Enter()

var Giving_exp = false

func Turn():
	match Check_for_finish_of_the_battle():
		"Player win":
			Team.LastBattleResult = true
			Giving_exp = true
			TextUpdate("You win!!")
			await Enter
			for Teamate in Team.team:
				var OldLevel = Teamate.Level
				var TotalExp = 0
				for Enemy in EnemyTeam:
					TotalExp += Enemy.Calculate_dropped_EXP(Teamate.Level, Team.team.size())
				await get_tree().create_timer(0.01).timeout
				TextUpdate(Teamate.Character_type + " has earned " + str(TotalExp) + " Exp!!")
				await Enter
				Teamate.Gain_EXP(TotalExp)
				if OldLevel != Teamate.Level:
					await get_tree().create_timer(0.01).timeout
					TextUpdate(Teamate.Character_type + " has reached level " + str(Teamate.Level) + "!!")
					await Enter
			Remove_Players()
			Finish_Battle.emit()
		"Enemys win":
			Team.LastBattleResult = false
			ViewDeathScreen()
			await  Finished_Death_Animation
			await Enter
			Finish_Battle.emit()
			Remove_Players()
			get_tree().get_first_node_in_group("Player").Reset()
		_: 
			if not is_turn_running:
				Next_turn()

func Remove_Players():
	for Teamate in PlayerTeam:
		remove_child(Teamate)

func ViewDeathScreen():  # Play the sound immediately
	await get_tree().create_timer(1).timeout  # Wait for 0.5 seconds
	$Music.stop()
	# Fade in the death screen gradually
	if not $Death.playing:
		$Death.play()
	var tween = create_tween()
	tween.tween_property($CanvasLayer/DeathScreen, "modulate:a", 1.0, 2)  # Durata di 1.875 secondi
	await tween.finished
	Finished_Death_Animation.emit()

func Check_for_finish_of_the_battle():
	var Enemys_Alive = 0
	for Enemy in EnemyTeam:
		if not Enemy.Faint:
			Enemys_Alive += 1
	if Enemys_Alive == 0:
		return "Player win"

	var Players_Alive = 0
	for Teamate in PlayerTeam:
		if not Teamate.Faint:
			Players_Alive += 1
	if Players_Alive == 0:
		return "Enemys win"

	return null

var is_turn_running = false

func Next_turn():
	is_turn_running = true
	TurnOrder[TurnIndex].Turn()
	await Finish_Turn
	TurnIndex += 1
	for battler: CharacterData in PlayerTeam + EnemyTeam:
		battler.EndTurn()
	if TurnIndex >= TurnOrder.size():
		End_round()
	is_turn_running = false

func Change_info(Character: CharacterData):
	$CanvasLayer/InfoBox.visible = true
	$CanvasLayer/InfoBox/Name.text = Character.Character_type + " L" + str(Character.Level)
	var Stats = Character.Calcolate_Stats()
	for Stat in Stats:
		$CanvasLayer/InfoBox/Stats.get_node(Stat + "/Label").text = str(Stats[Stat])
	$CanvasLayer/InfoBox/ProgressBar.max_value = Character.MaxEnergy
	$CanvasLayer/InfoBox/ProgressBar.value = Character.Energy
	$CanvasLayer/InfoBox/ProgressBar/Label.text = str(Character.Energy) + "/" + str(Character.MaxEnergy)

func Wait_Enter():
	while true:
		if Input.is_action_just_pressed("ui_accept") or (Input.is_action_just_pressed("Click_mouse") and Mause_in_battle_area):
			break
		await get_tree().create_timer(0.01).timeout
	Enter.emit()

func TextUpdate(Text: String) -> void:
	$CanvasLayer/TextBox/Text.text = Text

func Create_move_buttons(Character:CharacterData):
	for child in $CanvasLayer/Buttons.get_children():
		child.queue_free()
	var Index = 0
	for Move in Character.Current_Moves:
		var NewButton = MoveButton.new()
		NewButton.position.y = 50 * Index
		NewButton.text = Move
		if Character.Energy < Data.Move_data[Move]["Energy"]:
			NewButton.disabled =  true
		$CanvasLayer/Buttons.add_child(NewButton)
		Index += 1
	var NewButton = MoveButton.new()
	NewButton.position.y = 50 * Index
	NewButton.text = "Skip"
	var stylebox = StyleBoxFlat.new()
	$CanvasLayer/Buttons.add_child(NewButton)

var Selecting_Target = false
var Selected_move: String
var Selected_Target: CharacterData

func Get_move_from_player_input(Character:CharacterData):
	Selected_move = ""
	Create_move_buttons(Character)
	$CanvasLayer/Buttons.visible = true
	$CanvasLayer/Buttons.position = $Camera3D.unproject_position(Character.global_position) + Vector2(150,-150)
	while Selected_move == "":
		await get_tree().create_timer(0.01).timeout
	$CanvasLayer/Buttons.visible = false
	return Selected_move
	
func Get_target_from_player_input() -> CharacterData:
	Selected_Target = null
	Selecting_Target = true
	while Selected_Target == null:
		await get_tree().create_timer(0.01).timeout
	Selecting_Target = false
	return Selected_Target


func _on_click_area_mouse_entered():
	Mause_in_battle_area = true

func _on_click_area_mouse_exited():
	Mause_in_battle_area = false

func UseItem(Item: ItemData):
	Team.Inventory[Item] -= 1
	if Team.Inventory[Item] < 1:
		Team.Inventory.erase(Item)
	var Target = await Get_target_from_player_input()
	Target.Energy += Item.Energy
	Target.Take_damage(-Item.Heal)
	Target.Energy = min(Target.Energy, Target.MaxEnergy)
