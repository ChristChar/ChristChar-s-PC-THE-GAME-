extends Control

var SelectedItem: ItemData
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		visible = false

func ChengeSelectedItem(Item: ItemData):
	SelectedItem = Item
	UpdateInfos()

func UpdateInfos():
	if SelectedItem:
		$Infos.visible = true
		$Infos/Item.texture = SelectedItem.texture
		$Infos/descrizioe.text = SelectedItem.Description
		$Infos/Name.text = SelectedItem.Name + " x" + str(Team.Inventory[SelectedItem])
		$Infos/Button.visible = Team.Is_in_battle and SelectedItem.CanBeUsedInBattle()
	else:
		$Infos.visible = false

func _on_button_pressed():
	get_tree().get_first_node_in_group("Battle").UseItem(SelectedItem)
	visible = false
	$Items/ScrollContainer/VBoxContainer.Init_items()
	SelectedItem = null
	UpdateInfos()
