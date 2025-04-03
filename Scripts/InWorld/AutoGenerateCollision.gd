extends StaticBody3D

func _ready():
	set_collision_layer_value(2, true)
	set_collision_mask_value(2, true)
	for mesh_instance in get_children():
		if mesh_instance is MeshInstance3D:
			var mesh = mesh_instance.mesh
			if mesh:
				var collision_shape = CollisionShape3D.new()
				if mesh is BoxMesh:
						var box_shape = BoxShape3D.new()
						box_shape.extents = mesh.size / 2
						collision_shape.shape = box_shape
					# Gestione del SphereMesh
				elif mesh is SphereMesh:
						var sphere_shape = SphereShape3D.new()
						sphere_shape.radius = mesh.radius
						collision_shape.shape = sphere_shape
					# Gestione del CylinderMesh
				elif mesh is CylinderMesh:
						var cylinder_shape = CylinderShape3D.new()
						cylinder_shape.radius = mesh.radius
						cylinder_shape.height = mesh.height
						collision_shape.shape = cylinder_shape
					# Aggiungi ulteriori casi per altre forme geometriche se necessario
				# Aggiungi la CollisionShape3D come figlio
				add_child(collision_shape)
				# Imposta la posizione e la rotazione
				collision_shape.global_position = mesh_instance.global_position
				collision_shape.global_rotation = mesh_instance.global_rotation
