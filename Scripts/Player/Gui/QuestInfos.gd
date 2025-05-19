extends PanelContainer

var quest: Quest
var CompleteStyle: StyleBoxFlat

@onready var Progress = $VBoxContainer/Progress

# Called when the node enters the scene tree for the first time.
func _ready():
	$VBoxContainer.remove_child($VBoxContainer/Progress)
	if quest.Type == "Primary":
		var PrimeryStyle = get_theme_stylebox("panel").duplicate()
		PrimeryStyle.bg_color = Color8(150,175,255)
		PrimeryStyle.border_color = Color8(100,125,205)
		add_theme_stylebox_override("panel", PrimeryStyle)
	CompleteStyle = get_theme_stylebox("panel").duplicate()
	CompleteStyle.bg_color = Color8(0,255,0)
	CompleteStyle.border_color = Color8(0,205,0)
	quest.complete.connect(onComplete)
	name = quest.Name

func onComplete(quest):
	add_theme_stylebox_override("panel", CompleteStyle)

func HasBar(Key:String):
	for child in $VBoxContainer.get_children():
		if child.name == Key:
			return child
	return false

func Update():
	$VBoxContainer/Name.text = quest.Name
	$VBoxContainer/Description.text = quest.Description
	for key in quest.Progress:
		var Bar = HasBar(key)
		if not Bar:
			Bar = Progress.duplicate()
			Bar.name = key
			$VBoxContainer.add_child(Bar)
		Bar.get_node("Key").text = key
		Bar.max_value = quest.Objectives[key]
		Bar.value = quest.Progress[key]
		
