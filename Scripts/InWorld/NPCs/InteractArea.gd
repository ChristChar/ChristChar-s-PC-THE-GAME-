extends Area3D
class_name InteractArea

@export var range: float = 2
@export var Dialogue: DialogueResource
@export var AfterDestroy: bool = false
@export var Flag: String

func _ready():
	if Flag:
		if Team.Flags.has(Flag):
			if Team.Flags[Flag] and AfterDestroy:
				get_parent().queue_free()
		else:
			Team.Flags[Flag] = false
	var Collision = CollisionShape3D.new()
	var Shape = SphereShape3D.new()
	Shape.radius = range
	Collision.shape = Shape
	add_child(Collision)

func _process(delta):
	if Team.Pause:
		return
	if Input.is_key_pressed(KEY_E):
		for body in get_overlapping_bodies():
			if body is Player:
				Team.Pause = true
				Team.LastTalker = self
				DialogueManager.show_dialogue_balloon(Dialogue)
				await DialogueManager.dialogue_ended
				Team.Pause = false
				if AfterDestroy:
					get_parent().queue_free()
				if Flag:
					Team.Flags[Flag] = true
