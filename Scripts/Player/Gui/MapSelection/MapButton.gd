extends Button
class_name MapButton

var data: MapData

func _ready():
	icon = data.Icon
	icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	custom_minimum_size = Vector2(140,140)
	var Notifics = GetQuestNotification()
	if Notifics > 0:
		var Notification = Label.new()
		Notification.add_theme_font_size_override("font_size", 30)
		Notification.position = Vector2(125, 7.5)
		Notification.text = str(Notifics)
		var Style = StyleBoxFlat.new()
		Style.bg_color = Color(1,0,0)
		Style.corner_radius_bottom_left = 15
		Style.corner_radius_bottom_right = 15
		Style.corner_radius_top_left = 15
		Style.corner_radius_top_right = 15
		Notification.add_theme_stylebox_override("normal", Style)
		add_child(Notification)

func GetQuestNotification():
	var Count = 0
	for quest in Team.Quests.values():
		if quest.MapLocation == data.Name:
			Count += 1
	return Count

func _pressed():
	get_tree().get_first_node_in_group("MapSelector").ChangeSelecedMap(data)
