extends VBoxContainer


# Called when the node enters the scene tree for the first time.
func _ready():
	Init_characters()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func Create_Characters_dictonary() -> Dictionary:
	var Dictonary = {}
	for Character in Data.Character_Data:
		if not Data.Character_Data[Character]["IsEnemy"]:
			if  Data.Character_Data[Character]["Category"] in Dictonary:
				Dictonary[Data.Character_Data[Character]["Category"]].append(Character)
			else:
				Dictonary[Data.Character_Data[Character]["Category"]] = [Character]
	return Dictonary
		

func Create_label() -> Label:
	var NewLabel = Label.new()
	NewLabel.custom_minimum_size.y = 75
	NewLabel.add_theme_font_size_override("font_size", 40)
	NewLabel.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	return NewLabel

func Init_characters():
	for child in get_children():
		child.queue_free()
	var Characters = Create_Characters_dictonary()
	var BaseLabel = Create_label()
	for Category in Characters:
		var NewLabel = BaseLabel.duplicate()
		NewLabel.text = Category
		add_child(NewLabel)
		var Grid = GridContainer.new()
		Grid.columns = 4
		for Charcter in Characters[Category]:
			var NewIco = CharacterIcon.new()
			NewIco.character = Charcter
			Grid.add_child(NewIco)
		add_child(Grid)
		
	
