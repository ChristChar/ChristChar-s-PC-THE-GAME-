extends Node

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

func RGB_to_color(RGB:Array):
	if RGB.size() > 3:
		return Color(RGB[0] / 255.0, RGB[1] / 255.0, RGB[2] / 255.0, RGB[3] / 255.0)
	else:
		return Color(RGB[0] / 255.0, RGB[1] / 255.0, RGB[2] / 255.0)

func is_closer_to_white(color: Color) -> bool:
	var brightness = 0.299 * color.r + 0.587 * color.g + 0.114 * color.b
	return brightness > 0.5  # True se è più vicino al bianco, False se al nero

func GetShader(Name: String):
	for shader in Read_json("res://addons/sprite-shader-mixer/assets/shaders/shaders.json"):
		if shader.name == Name:
			return shader

func Create_Shader_Mixed(Shaders:Array) -> ShaderMaterial:
	var ShaderInfosArray: Array[ShaderInfo] = []
	for shader in Shaders:
		var NewShaderInfo = ShaderInfo.new()
		NewShaderInfo.loadShaderInfo(GetShader(shader))
		ShaderInfosArray.append(NewShaderInfo)
	var code = ShaderInfo.generateShaderCode(ShaderInfosArray)
	# Richiesta di generazione: il mixer crea un .tres in memoria
	var mat := ShaderMaterial.new() 
	mat.shader = code
	return mat
