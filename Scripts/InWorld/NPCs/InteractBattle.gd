extends InteractArea

@export var BattleJson: String

func _process(delta):
	if Team.Pause:
		return
	if Input.is_key_pressed(KEY_E):
		for body in get_overlapping_bodies():
			if body is Player:
				Team.Pause = true
				Team.LastTalker = self
				DialogueManager.show_dialogue_balloon(Dialogue)
				await DialogueManager.dialogue_ended
				Team.GenerateBattleFromJSON(BattleJson)
				await Team.FinishedBattle
				if not Team.LastBattleResult:
					return
				Team.Pause = true
				DialogueManager.show_dialogue_balloon(Dialogue, "AfterBattle")
				await DialogueManager.dialogue_ended
				Team.Pause = false
				if AfterDestroy:
					Team.Flags[Flag] = true
					get_parent().queue_free()
				
