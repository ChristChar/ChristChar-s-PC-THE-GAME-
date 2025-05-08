extends Path3D
	   # Amplitude of the sideways wobble
@export var StartCross: Dictionary[NodePath, bool] = {}
@export var EndCross: Dictionary[NodePath, bool] = {}
  # Velocità del movimento lungo il percorso

func _process(delta: float) -> void:
	if Team.Pause:
		return
	# Itera su tutti i figli di questo Path3D
	for child in get_children():
		if child is PathFollow3D:
			# Incrementa l'offset unitario basandoti sul delta
			if child.Invert:
				child.progress -= child.speed * delta
			else:
				child.progress += child.speed  * delta
			
			# Se l'unit_offset supera 1, lo riavvolgiamo all'inizio del percorso
			if (child.progress_ratio >= 0.99 and not child.Invert) or (child.progress_ratio <= 0.01 and child.Invert):
				if child.Invert:
					if not StartCross.is_empty():
						var NewPath = StartCross.keys().pick_random()
						child.Invert = StartCross[NewPath]
						child.progress_ratio = 1.0 if child.Invert else 0
						remove_child(child)
						get_node(NewPath).add_child(child)
					else:
						child.Invert = not child.Invert
				else:
					if not EndCross.is_empty():
						var NewPath = EndCross.keys().pick_random()
						child.Invert = EndCross[NewPath]
						child.progress_ratio = 1.0 if child.Invert else 0
						remove_child(child)
						get_node(NewPath).add_child(child)
					else:
						child.Invert = not child.Invert
