extends GridContainer

const Path = "res://Data/Resources/Maps/"

var Maps = [
	preload(Path + "ChristChar's PC.tres")
]

func _ready():
	for map in Maps:
		var NewButton = MapButton.new()
		NewButton.data = map
		add_child(NewButton)
