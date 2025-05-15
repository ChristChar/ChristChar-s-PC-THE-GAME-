extends GridContainer

func Update():
	for child in get_children():
		child.queue_free()
	for map: MapData in Team.MapsData:
		if map.Unlock:
			var NewButton = MapButton.new()
			NewButton.data = map
			add_child(NewButton)


func _ready():
	Update()
