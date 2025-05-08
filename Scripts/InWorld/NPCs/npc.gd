extends CharacterBody3D
class_name NPC

const DialoguePath = "res://Data/Dialogue/Casual NPC/"

var Dialogues = [
	preload(DialoguePath + "I hate u.dialogue"),
	preload(DialoguePath + "I like cats.dialogue"),
	preload(DialoguePath + "My yt channel.dialogue"),
	preload(DialoguePath + "dark web.dialogue")
]

func _ready():
	$Base.play("Walk")
	$Shirt.play(str(randi_range(1,3)))
	$Shirt.visible = randf() > 0.2
	$InteractArea.Dialogue = Dialogues.pick_random()

func _process(delta):
	global_rotation = Vector3.ZERO

func ChangeDireciton(Driection: bool):
	$Base.flip_h = Driection
	$Shirt.flip_h = Driection
