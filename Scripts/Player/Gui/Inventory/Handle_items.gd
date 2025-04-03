extends VBoxContainer


# Called when the node enters the scene tree for the first time.
func _ready():
	Init_items()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func Create_items_dictonary() -> Dictionary:
	var Dictonary = {}
	for Item in Team.Inventory:
		if Item.Category in Dictonary:
			Dictonary[Item.Category].append(Item)
		else:
			Dictonary[Item.Category] = [Item]
	return Dictonary
		

func Create_label() -> Label:
	var NewLabel = Label.new()
	NewLabel.custom_minimum_size.y = 75
	NewLabel.add_theme_font_size_override("font_size", 40)
	NewLabel.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	return NewLabel

func Init_items():
	for child in get_children():
		child.queue_free()
	var Items = Create_items_dictonary()
	var BaseLabel = Create_label()
	for Category in Items:
		var NewLabel = BaseLabel.duplicate()
		NewLabel.text = Category
		add_child(NewLabel)
		var Grid = GridContainer.new()
		Grid.columns = 4
		for Item in Items[Category]:
			var NewIco = ItemIcon.new()
			NewIco.Item = Item
			Grid.add_child(NewIco)
		add_child(Grid)
		
	
