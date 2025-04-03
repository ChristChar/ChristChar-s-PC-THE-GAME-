extends VBoxContainer


# Called when the node enters the scene tree for the first time.
func _ready():
	Set_team()

func Set_team():
	for i in range(4):
		var Icon = CharacterIcon.new()
		Icon.IsTeam = true
		var Character
		if Team.team.size() <= i:
			Character = ""
		else:
			Character = Team.team[i].Character_type
		Icon.character = Character
		add_child(Icon)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
