extends PathFollow3D

var Invert = false
var speed: float

func _ready():
	Invert = randf() < 0.5
	speed = randf_range(2,6)
	h_offset = randf_range(-3,3)
	v_offset = 0.7

func _process(delta):
	$Npc.ChangeDireciton(Invert)
