extends StaticBody2D

@export var file: String
@export var Dialogue: DialogueResource
@export var Once: bool
@export var After_Eliminate: bool
var You_can_do_it = true
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if You_can_do_it and not Team.Pause:
		if Input.is_key_pressed(KEY_E):
			for body in $InteractArea.get_overlapping_bodies():
				if body is Player:
					DialogueManager.show_dialogue_balloon(Dialogue, "Start")
					if After_Eliminate:
						queue_free()
					if Once:
						You_can_do_it = false
