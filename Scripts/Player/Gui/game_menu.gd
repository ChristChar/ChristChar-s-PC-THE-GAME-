extends Control

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		if not Team.Is_in_battle:
			visible = not visible
			if visible:
				Update()
			Team.Pause = visible


func _on_resume_pressed():
	visible = false
	Team.Pause =  false

func Update():
	UpdateTeamInfos()
	UpdateQuestsInfos()
	$IPoints/Label.text = str(Team.IPoints)

func UpdateTeamInfos():
	var Index = 0
	for Character in Team.team:
		var CharacterInfo
		if $TeamInfos.get_child_count() < Index + 1:
			CharacterInfo = preload("res://Scenes/Gui/InGameMenu/CharacterInfos.tscn").instantiate()
			$TeamInfos.add_child(CharacterInfo)
		else:
			CharacterInfo = $TeamInfos.get_child(Index)
		CharacterInfo.Character = Character
		CharacterInfo.Update()
		Index += 1

func HasQuest(Key:String):
	for child in $ScrollContainer/QuestInfos.get_children():
		if child.name == Key:
			return child
	for child in $ScrollContainer/QuestInfos/Primary.get_children():
		if child.name == Key:
			return child
	return false

func UpdateQuestsInfos():
	var Index = 0
	for quest: Quest in Team.Quests.values():
		var QuestInfo = HasQuest(quest.Name)
		if not QuestInfo:
			QuestInfo = preload("res://Scenes/Gui/InGameMenu/QuestInfos.tscn").instantiate()
			QuestInfo.quest = quest
			if quest.Type == "Primary":
				$ScrollContainer/QuestInfos/Primary.add_child(QuestInfo)
			else:
				$ScrollContainer/QuestInfos.add_child(QuestInfo)
		QuestInfo.Update()
		Index += 1

func _on_back_to_menu_pressed():
	get_tree().get_first_node_in_group("Game").queue_free()
	get_tree().get_first_node_in_group("Menu").visible = true
	get_tree().get_first_node_in_group("Menu").get_node("MapSelector/Maps/ScrollContainer/GridContainer").Update()
	Team.Pause =  false


func _on_inventory_pressed():
	$Inventory.visible = true


func _on_team_pressed():
	$TeamViewer.visible = true
