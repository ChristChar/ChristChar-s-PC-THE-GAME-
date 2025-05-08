@tool
extends EditorExportPlugin

func _export_begin(
	features: PackedStringArray,
	is_debug: bool,
	path: String,
	flags: int
) -> void:
	var team = preload("res://Scripts/Autoload/Team.gd").new()
	# Qui puoi inserire qualunque logica da eseguire all'inizio dell'export
	for character in Read_json("res://Data/Json/Personaggi.json"):
		generate_and_save_frames(character, Read_json("res://Data/Json/SpecificAnimations.json"), team.animations)

# Funzione principale per generare e salvare SpriteFrames
func generate_and_save_frames(character_type: String, data: Dictionary, animations: Array) -> void:
	var BASE_PATH = "res://Resources/Images/Characters/"
	var new_frames := SpriteFrames.new()

	new_frames.remove_animation("default")
	for animation in animations:
		var anim_folder = BASE_PATH + character_type + "/" + animation
		new_frames.add_animation(animation)
		if DirAccess.dir_exists_absolute(anim_folder):
			var file_list = get_files_in_directory(anim_folder)
			for file_name in file_list:
				if file_name.get_extension().to_lower() == "png":
					var tex_path = anim_folder + "/" + file_name
					var texture := load(tex_path)
					new_frames.add_frame(animation, texture)
			if data.has(character_type) and data[character_type].has(animation):
				var spec = data[character_type][animation]
				if spec.has("Loop"):
					new_frames.set_animation_loop(animation, spec["Loop"])
				if spec.has("Framerate"):
					new_frames.set_animation_speed(animation, spec["Framerate"])
		else:
			push_warning("Directory non trovata: %s" % anim_folder)

	var save_path = "res://Data/CharacterInBattleSpriteFrames/" + character_type + ".tres"
	var err = ResourceSaver.save(new_frames, save_path)
	if err == OK:
		print("SpriteFrames salvato in: %s" % save_path)
	else:
		push_error("Errore nel salvataggio di SpriteFrames: %s" % save_path)

# Utility: ottiene i file in una directory (ricorsiv

func get_files_in_directory(path: String) -> Array:
	var dir = DirAccess.open(path)
	var files = []
	
	if dir:
		dir.list_dir_begin()  # True per includere sottodirectory, false per non mostrare il percorso completo

		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir():  # Verifica che l'elemento sia un file
				files.append(file_name)
			file_name = dir.get_next()
		
		dir.list_dir_end()
	else:
		print("Errore nell'aprire la directory: " + path)
	
	return files

func Read_json(FilePath:String):
	var json_as_text = FileAccess.get_file_as_string(FilePath)
	return JSON.parse_string(json_as_text)
