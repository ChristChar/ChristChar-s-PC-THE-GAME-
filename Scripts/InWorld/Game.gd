extends Node3D

@onready var  Enviroment = $WorldEnvironment.environment

var data: MapData
var CurrentMap: Map

func _ready():
	add_child(data.Scene.instantiate())
	get_tree().get_first_node_in_group("Player").Reset()
	CurrentMap = $Map

func ChangeMap(Map:String, Spawn:NodePath):
	add_child(load(Map).instantiate())
	if $SubMap:
		$WorldEnvironment.environment = null
		$SubMap.global_position.y += 15
		$Map.visible = false
		for friend in get_tree().get_nodes_in_group("Friend"):
			friend.global_position = $SubMap.get_node(Spawn).global_position+ Vector3(randf_range(-1, 1),0, randf_range(-1, 1))
		$Music.stream = $SubMap.Music
		CurrentMap = $SubMap
	else:
		print("mi sa che hai rinominato male il root dalla submap")

func SubChangeMap(Map:String, Spawn:NodePath):
	if $SubMap:
		$SubMap.queue_free()
	else:
		print("mi sa che la submap non esitse, SCEMO!!")
		return
	add_child(load(Map).instantiate())
	if $SubMap:
		$SubMap.global_position.y += 15
		for friend in get_tree().get_nodes_in_group("Friend"):
			friend.global_position = $SubMap.get_node(Spawn).global_position+ Vector3(randf_range(-1, 1),0, randf_range(-1, 1))
		$Music.stream = $SubMap.Music
		CurrentMap = $SubMap
	else:
		print("mi sa che hai rinominato male il root dalla submap")

func ReturnToMainMap(Spawn:NodePath):
	var SubMap = $SubMap
	if SubMap:
		SubMap.queue_free()
		$Map.visible = true
		$Music.stream = $Map.Music
		for friend in get_tree().get_nodes_in_group("Friend"):
			friend.global_position = $Map.get_node(Spawn).global_position + Vector3(randf_range(-1, 1),0, randf_range(-1, 1))
		$WorldEnvironment.environment = Enviroment
		CurrentMap = $Map
