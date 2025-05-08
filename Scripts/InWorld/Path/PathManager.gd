extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(20):
		get_children().pick_random().add_child(preload("res://Scenes/NpcFOllow.tscn").instantiate())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
