extends Button
class_name MapButton

var data: MapData

func _ready():
	icon = data.Icon
	icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	custom_minimum_size = Vector2(140,140)

func _pressed():
	get_tree().get_first_node_in_group("MapSelector").ChangeSelecedMap(data)
