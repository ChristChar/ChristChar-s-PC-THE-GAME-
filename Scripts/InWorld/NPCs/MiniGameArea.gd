extends InteractArea

@export var MiniGame: String
@export var MinScore: int = 30

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
				var Score = await Team.StartMiniGame(MiniGame).GameFinished
				if Score >= MinScore:
					DialogueManager.show_dialogue_balloon(Dialogue, "Win")
					await DialogueManager.dialogue_ended
					if AfterDestroy:
						Team.Flags[Flag] = true
						get_parent().queue_free()
				else:
					DialogueManager.show_dialogue_balloon(Dialogue, "Lose")
					await DialogueManager.dialogue_ended
				Team.Pause = false
