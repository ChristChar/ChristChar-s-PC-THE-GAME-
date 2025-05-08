extends SubViewport

@onready var vp := SubViewport.new()
@onready var cam := Camera3D.new()

var Encounters = {}

func _ready():
	# 1) Configura SubViewport
	vp.size = Vector2i(500, 500)
	vp.render_target_update_mode = SubViewport.UPDATE_ONCE
	# Usa lo stesso World3D della scena principale
	vp.world_3d = get_viewport().world_3d
	add_child(vp)


	# 3) Configura camera
	cam.transform.origin = Vector3(0, 50, 0)
	cam.transform.basis = Basis().rotated(Vector3(1,0,0), deg_to_rad(-90))
	cam.projection  = cam.PROJECTION_ORTHOGONAL
	cam.size = 100
	cam.near = 1
	cam.far = 200
	vp.add_child(cam)

	# 4) Dopo il primo frame, assegna la texture
	await RenderingServer.frame_post_draw
	$Map.texture = vp.get_texture()
	for encounter in get_tree().get_nodes_in_group("Encounter"):
		var NewIcon = TextureRect.new()
		NewIcon.texture = preload("res://Resources/Images/Gui/Map/Enemy.png")
		Encounters[encounter] = NewIcon
		add_child(NewIcon)

func _process(delta):
	var PlayerPos: Vector3 = get_tree().get_first_node_in_group("Player").global_position
	# Imposta lo sfondo in modo che il giocatore sia al centro
	$Map.position = -Vector2(PlayerPos.x, PlayerPos.z) * 5 - Vector2(128,128)
	$Character.rotation = get_tree().get_first_node_in_group("Player").LastDirection.angle()
	# Calcola la posizione relativa degli incontri sottraendo la posizione del giocatore
	for encounter in Encounters.keys():
		if is_instance_valid(encounter):
			var relative_pos = Vector2(encounter.global_position.x, encounter.global_position.z) - Vector2(PlayerPos.x, PlayerPos.z)
			Encounters[encounter].position = relative_pos * 5 + Vector2(128,128)
		else:
			Encounters[encounter].queue_free()
			Encounters.erase(encounter)
