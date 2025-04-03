extends Button
class_name ItemIcon

var Item: ItemData
var NumberLabel := Label.new()
# Called when the node enters the scene tree for the first time.
func _ready():
	size = Vector2(100,100)
	custom_minimum_size = Vector2(100,100)
	tooltip_text = Item.Name
	icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon = Item.texture
	NumberLabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	NumberLabel.add_theme_font_size_override("font_size", 35)
	NumberLabel.position = Vector2(70, 50)
	UpdateLabel()
	add_child(NumberLabel)

func UpdateLabel():
	NumberLabel.text = str(Team.Inventory[Item])

func _pressed():
	get_tree().get_first_node_in_group("Inventory").ChengeSelectedItem(Item)
# Called every frame. 'delta' is the elapsed time since the previous frame.
