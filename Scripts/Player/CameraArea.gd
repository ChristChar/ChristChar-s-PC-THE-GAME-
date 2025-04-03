extends Area3D

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	for child in body.get_children():
		if child is MeshInstance3D:
			# Duplica la mesh per renderla unica
			var mesh_copiata = child.mesh.duplicate()
			# Duplica il materiale per renderlo unico
			var material = mesh_copiata.surface_get_material(0).duplicate()
			material.albedo_color = Color(1, 1, 1, 0.3)
			mesh_copiata.surface_set_material(0, material)
			child.mesh = mesh_copiata
		_on_body_entered(child)

func _on_body_exited(body):
	for child in body.get_children():
		if child is MeshInstance3D:
			# Duplica la mesh per renderla unica
			var mesh_copiata = child.mesh.duplicate()
			# Duplica il materiale per renderlo unico
			var material = mesh_copiata.surface_get_material(0).duplicate()
			material.albedo_color = Color(1, 1, 1, 1)
			mesh_copiata.surface_set_material(0, material)
			child.mesh = mesh_copiata
		_on_body_exited(child)
