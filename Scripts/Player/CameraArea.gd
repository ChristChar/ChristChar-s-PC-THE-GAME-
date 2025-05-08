extends Area3D

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	Set_transparency(body, 0.15)

func Set_transparency(node: Node, alpha: float):
	for child in node.get_children():
		if child is MeshInstance3D:
			# Duplica il mesh e il materiale
			var new_mesh = child.mesh.duplicate(true)
			var mat = new_mesh.surface_get_material(0)
			if mat:
				mat = mat.duplicate(true)
				# Imposta colore e canale alfa
				mat.albedo_color = Color(1,1,1, alpha)
				# Abilita la trasparenza in alpha‑blend
				mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
				# Opzionale: disabilita culling e regola depth draw
				mat.cull_mode = BaseMaterial3D.CULL_DISABLED
				mat.depth_draw_mode = BaseMaterial3D.DEPTH_DRAW_ALWAYS
				new_mesh.surface_set_material(0, mat)
			child.mesh = new_mesh
		# Ricorsione sui figli
		Set_transparency(child, alpha)

	

func _on_body_exited(body):
	Set_transparency(body, 1.0)
