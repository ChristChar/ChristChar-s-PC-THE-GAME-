extends Sprite3D

@export var camera: Camera3D
@export var subviewport: SubViewport

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		# 1. Raycast per trovare lo Sprite3D
		var from = camera.project_ray_origin(event.position)
		var to   = from + camera.project_ray_normal(event.position) * 1000
		var params = PhysicsRayQueryParameters3D.create(from, to)
		params.collide_with_areas = true
		var res = get_world_3d().direct_space_state.intersect_ray(params)

		# 2. Se colpisce il tuo Sprite3D...
		if res and res.collider == self:
			var local = to_local(res.position)
			var tex_size = texture.get_size()
			var uv = Vector2((local.x/tex_size.x)+0.5, (-local.y/tex_size.y)+0.5)
			var click_pos = uv * subviewport.size

			# 3. Inoltra copia dell’evento alla SubViewport
			var click = event.duplicate() as InputEventMouseButton
			click.position = click_pos
			subviewport.push_input(click)
