extends Area3D
class_name CharacterData

# Variabili del personaggio
var Character_type: String = "Gino"
var CurrentParticle = "Damage"
var LastMoveUsed = "Hit" 
var Level = 5
var EXP = 0
var Original_ZIndex: int
var DamagePartclesTimer = 0
var ReturnToIdle = 0
var Energy = 0
var MaxEnergy = 0
var Protected = 0
var HP: int
var StartPosition: Vector3
var Current_Moves = []
var Learnable_Moves = []
var Status = {}
var StatModific = {"HP":0,"ATT":0,"DIF":0,"PI":0,"INT":0,"SPEED":0}
var IsEnemy = false
var Boss = false
var Faint = false
var Focus = false
var Attacking = false
var AttTarget: CharacterData
var animation: Dictionary

var LifeBar := ProgressBar.new()
var AnimatedSprite := AnimatedSprite2D.new()
var SV := SubViewport.new()
var Shield := Sprite2D.new()

var HealthBar = "res://Scenes/BarraDellaVita.tscn"

const Particles = {
	"Damage":"res://Scenes/Particles/Damage.tscn",
	"DamageText":"res://Scenes/Particles/DamageText.tscn",
	"Failed":"res://Scenes/Particles/Failed.tscn",
	"Poison":"res://Scenes/Particles/Poison.tscn",
	"LowerStat": "res://Scenes/Particles/LowerStat.tscn",
	"UpperStat": "res://Scenes/Particles/UpperStat.tscn",
	"Angry": "res://Scenes/Particles/Angry.tscn",
	"Glitch": "res://Scenes/Particles/Glitch.tscn",
	"NoInternet": "res://Scenes/Particles/NoInternet.tscn"
}
const  Audios = {
	"Hit":  "res://Resources/Sounds/BattleSounds/Hit.mp3",
	"Fail": "res://Resources/Sounds/BattleSounds/Fail.mp3",
	"Dead": "res://Resources/Sounds/BattleSounds/DeathBong.mp3",
	"Sleep": "res://Resources/Sounds/BattleSounds/Sleep.mp3",
	"Heal": "res://Resources/Sounds/BattleSounds/Heal.mp3",
	"UpperStatS": "res://Resources/Sounds/BattleSounds/UpperStat.mp3",
	"LowerStatS": "res://Resources/Sounds/BattleSounds/LowerStat.mp3",
	"Shield": "res://Resources/Sounds/BattleSounds/Shield.mp3"
}
const StatModificMoltp = {
	-6: 0.25,
	-5: 0.2857,
	-4: 0.33,
	-3: 0.4,
	-2: 0.5,
	-1: 0.67,
	0: 1,
	1: 1.5,
	2: 2,
	3: 2.5,
	4: 3,
	5: 3.5,
	6: 4
}

var StatusData: = {
	"Poison": {
		"Function":Poison
		},
	"Puppet": {
		"Function":Poison
		},
	"Angry": {
		"Stat":{
			"ATT": 1.5,
			"DIF": 0.75
		}
	},
	"Glitch": {
		"Function":Poison,
		"Skip": 25,
		"Stat": {
			"PI": 0.75
		},
		"Shader": "Glitch"
	},
	"NoInternet": {
		"Skip": 40,
		"Stat": {
			"SPEED": 0.5
		},
		"Shader": "Glitch"
	},
	"Half": {
		"Stat": {
			"ATT": 0.5
		},
		"Shader": "Half"
	},
	"Ban": {
		"Skip": 100,
		"Shader": "Greyscale",
		"TurnFunction":RemoveEffect
	},
	"Repeat": {
		"Function":RemoveEffect
	}
}

signal Finish_Attack()

func Poison(Effect:String):
	Take_damage(Calcolate_Stat("HP") * Status[Effect] / 100)
	Start_Particles(Effect)

func RemoveEffect(Effect:String):
	Status[Effect] -= 1
	if Status[Effect] <= 0:
		Status.erase(Effect)
		UpdateEffectsIcon()

func EndRound():
	if Faint:
		return
	for s in Status:
		if "Function" in StatusData[s]:
			StatusData[s]["Function"].call(s)

func EndTurn():
	if Faint:
		return
	if Protected > 0:
		Protected -= 1
	for s in Status:
		if "TurnFunction" in StatusData[s]:
			StatusData[s]["TurnFunction"].call(s)

func UpdateEffectsIcon():
	var Grid: GridContainer = LifeBar.get_node("Effects")
	for child in Grid.get_children():
		child.queue_free()
	var shaders = []
	for s in Status:
		if "Shader" in StatusData[s]:
			shaders.append(StatusData[s]["Shader"])
		var texture = TextureRect.new()
		texture.texture = load("res://Resources/Images/Icone/Effect/" + s + ".png")
		Grid.add_child(texture)
	if shaders.size() > 0:
		AnimatedSprite.material = File.Create_Shader_Mixed(shaders)
	else:
		AnimatedSprite.material = null

func _init(type, level:int = 10, boss: bool = false):
	MaxEnergy = Data.Character_Data[Character_type]["MaxEnergia"]
	if type is CharacterSave:
		Level = type.Level
		Character_type = type.Character_type
		EXP = type.EXP
		Current_Moves = type.Current_Moves
		Learnable_Moves = type.Learnable_Moves
	else:
		Character_type = type
		Level = level
		Boss = boss
	Energy = MaxEnergy
	HP = Calcolate_Stat("HP")
	Calcolate_Learnable_Moves()
	if Current_Moves == []:
		assign_moves()

func GenerateSave() -> CharacterSave:
	var NewSave = CharacterSave.new()
	NewSave.Level = Level
	NewSave.Character_type = Character_type
	NewSave.HP = HP
	NewSave.EXP = EXP
	NewSave.Current_Moves = Current_Moves
	NewSave.Learnable_Moves = Learnable_Moves
	NewSave.Energy = Energy
	NewSave.Faint = Faint
	return NewSave

func _ready():
	StartPosition = global_position
	add_to_group("Combattente")
	# Configurazione CollisionShape2D
	var NewShape = CollisionShape3D.new()
	var Shape = BoxShape3D.new()
	Shape.size = Vector3(3,3,0.5)
	NewShape.shape = Shape
	add_child(NewShape)
	# Configurazione AnimatedSprite2D
	var NewFrames = SpriteFrames.new()
	if OS.has_feature("editor"):
		for animation in Team.animations:
			var Path = "res://Resources/Images/Characters/" + Character_type + "/" + animation
			NewFrames.add_animation(animation)
			if DirAccess.dir_exists_absolute(Path):
				for Frame in File.get_files_in_directory(Path):
					if Frame.get_extension() == "png":
						NewFrames.add_frame(animation, load(Path + "/" + Frame))
				if Character_type in Data.Specific_Animations and animation in Data.Specific_Animations[Character_type]:
					if "Loop" in Data.Specific_Animations[Character_type][animation]:
						NewFrames.set_animation_loop(animation,Data.Specific_Animations[Character_type][animation]["Loop"])
					if "Framerate" in Data.Specific_Animations[Character_type][animation]:
						NewFrames.set_animation_speed(animation, Data.Specific_Animations[Character_type][animation]["Framerate"])
	else:
		NewFrames = load("res://Data/CharacterInBattleSpriteFrames/" + Character_type + ".tres")
	AnimatedSprite.sprite_frames = NewFrames
	if IsEnemy:
		AnimatedSprite.flip_h = true
	AnimatedSprite.play("Idle")
	AnimatedSprite.position = Vector2(300,300)
	SV.size = Vector2(600,600)
	SV.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	SV.transparent_bg = true
	add_child(SV)
	var Sprt = Sprite3D.new()
	Sprt.position.z = 0.2
	if Boss:
		Sprt.scale = Vector3(1.25,1.25,1.25)
		position.y *= 1.25
	Sprt.texture = SV.get_texture()
	add_child(Sprt)
	Sprt.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	Sprt.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
		# 4. Abilita la modalità di alpha cut pre‐pass
	Sprt.alpha_cut     = SpriteBase3D.ALPHA_CUT_OPAQUE_PREPASS
	Sprt.alpha_scissor_threshold = 0.5
	Sprt.billboard = BaseMaterial3D.BILLBOARD_DISABLED
	SV.add_child(AnimatedSprite)
	Shield.texture = preload("res://Resources/Images/BattleAnimations/Shield.png")
	Shield.modulate = Color(1,1,1,0.65)
	Shield.scale = Vector2(5,5)
	Shield.position = Vector2(300,300)
	Shield.visible = false
	SV.add_child(Shield)
	# Configurazione barra della vita
	var BarScene: String
	if "CustomBar" in Data.Character_Data[Character_type]:
		BarScene = Data.Character_Data[Character_type]["CustomBar"]
	else:
		BarScene = HealthBar
	LifeBar = load(BarScene).instantiate()
	LifeBar.position = Vector2(-140 + 300, -175 + 300)
	LifeBar.max_value = HP
	SV.add_child(LifeBar)
	
	#Configurazione particles
	for Particle in Particles:
		var NewParticle = load(Particles[Particle]).instantiate()
		NewParticle.name = Particle
		NewParticle.scale = Vector2(2,2)
		NewParticle.position = Vector2(300,300)
		SV.add_child(NewParticle)
	
	#Configurazione suoni
	var Path = "res://Resources/Sounds/Characters/" + Character_type
	for Sound in Audios:
		var AudioLoaded = load(Path + "/" + Sound + ".mp3")
		var NewAudioStreamPlayer = AudioStreamPlayer.new()
		NewAudioStreamPlayer.name = Sound
		if AudioLoaded:
			NewAudioStreamPlayer.stream = AudioLoaded
		else:
			NewAudioStreamPlayer.stream = load(Audios[Sound])
		add_child(NewAudioStreamPlayer)
	# Collegamento segnali
	connect("mouse_entered", Info)
	connect("mouse_exited", Not_Info)
	UpdateEffectsIcon()
	

func Info():
	get_parent().Change_info(self)
	if not Faint and get_parent().Selecting_Target:
		FocusSwitch(true)

func Not_Info():
	FocusSwitch(false)

func FocusSwitch(on:bool):
	var scaleValue = 1.3 if on else 1
	AnimatedSprite.scale = Vector2(scaleValue,scaleValue)
	Focus = on

func DIE():
	FocusSwitch(false)
	Faint = true
	LifeBar.visible = false
	if AnimatedSprite.sprite_frames.get_frame_count("Dying") > 0:
		Start_anmation("Dying", 1)
	else:
		AnimatedSprite.play("Dead")
	Play_Sound("Dead")
	if IsEnemy:
		Team.AddQuestProgress("Enemy")
		Team.AddQuestProgress("Enemy " + Character_type)

func Reset():
	HP = Calcolate_Stat("HP")
	Faint = false
	StatModific = {"HP":0,"ATT":0,"DIF":0,"PI":0,"INT":0,"SPEED":0}
	LifeBar.visible = true
	LifeBar.value = Calcolate_Stat("HP")
	AnimatedSprite.play("Idle")
	Energy = MaxEnergy
	Protected = 0
	IsEnemy = false
	if Status.size() > 0:
		Status = {}
		UpdateEffectsIcon()

func DoIDoParticles() -> bool:
	if "Damage" in animation:
		return animation["Damage"]
	elif AttTarget.Protected > 0:
		return false
	return true

func _process(delta):
	if Focus and get_parent().Selecting_Target:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			get_parent().Selected_Target = self
	if Attacking:
		match animation["Type"]:
			"Follow":
				if global_position.distance_to(AttTarget.global_position) < 0.2:
					Attacking = false
					if DoIDoParticles():
						AttTarget.Start_Particles("Damage")
					global_position = StartPosition
					AnimatedSprite.play("Idle")
					Finish_Attack.emit()
				else:
					global_position = lerp(global_position, AttTarget.global_position, animation["Speed"])
			"ThrowObject":
				if $Object:
					if $Object.global_position.distance_to(AttTarget.global_position) < 0.2:
						Attacking = false
						if DoIDoParticles():
							AttTarget.Start_Particles("Damage")
						$Object.queue_free()
						AnimatedSprite.play("Idle")
						Finish_Attack.emit()
					else:
						$Object.global_position = lerp($Object.global_position, AttTarget.global_position, animation["Speed"])
						if animation["Spinning"]:
							$Object.rotation.x += delta * 10
				else:
					var NewObject = Sprite3D.new()
					NewObject.texture = load(animation["Sprite"])
					NewObject.name = "Object"
					add_child(NewObject)
			"Laser":
				if $LaserCylinder:
					var cyl   = $LaserCylinder as MeshInstance3D
					var end   = AttTarget.global_position
					var dist  = cyl.global_position.distance_to(end)

					cyl.global_position = cyl.global_position.move_toward(end, delta * 25)
				
					# 5) Fine azione
					if dist < 0.2:
						cyl.queue_free()
						Attacking = false
						if DoIDoParticles():
							AttTarget.Start_Particles("Damage")
						AnimatedSprite.play("Idle")
						Finish_Attack.emit()
				else:
					# Creazione iniziale identica
					var cyl = MeshInstance3D.new()
					cyl.name = "LaserCylinder"
					var mesh = CylinderMesh.new()
					mesh.top_radius    = 0.25
					mesh.bottom_radius = 0.25
					mesh.height        = 1
					cyl.mesh = mesh
					cyl.rotation = Vector3(0,0, TAU/4)
					add_child(cyl)
			"ExpandingCircle":
				if animation.has("CurrentRadius") and $CircleMesh:
					animation["CurrentRadius"] += animation["Speed"] * delta
					$CircleMesh.scale = Vector3.ONE * animation["CurrentRadius"]
					if animation["CurrentRadius"] >= animation["Radius"]:
						$CircleMesh.queue_free()
						Attacking = false
						emit_signal("Finish_Attack")
				else:
					animation["CurrentRadius"] = 1.0
					# inline spawn
					var cm = MeshInstance3D.new()
					cm.name = "CircleMesh"
					var sm = SphereMesh.new()
					var mt = StandardMaterial3D.new()
					mt.albedo_color = File.RGB_to_color(animation["Color"])
					mt.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_HASH
					sm.material = mt
					cm.mesh = sm
					cm.scale = Vector3.ONE * animation["CurrentRadius"]
					add_child(cm)
			"ObjectGust":
				if "objects" in animation:
					animation["NewObjectCountdown"] -= delta
					if animation["NewObjectCountdown"] <= 0 and animation["ObjetcsCount"] + animation["objects"].size() < 10:
						animation["NewObjectCountdown"] = randf_range(0.1,0.25)
						var NewSprite = Sprite3D.new()
						NewSprite.texture = load(animation["Sprites"].pick_random())
						if animation["Spinning"]:
							NewSprite.rotation = Vector3(0,0,randf_range(0, TAU))
						animation["objects"].append(NewSprite)
						add_child(NewSprite)
					for object: Sprite3D in animation["objects"]:
						object.global_position = object.global_position.move_toward(AttTarget.global_position, animation["Speed"] * delta)
						if animation["Spinning"]:
							object.rotation.z += delta * 10
						if object.global_position.distance_to(AttTarget.global_position) < 0.2:
							if DoIDoParticles():
								AttTarget.Start_Particles("Damage")
								AttTarget.Play_Sound("Hit")
							animation["objects"].erase(object)
							object.queue_free()
							animation["ObjetcsCount"] += 1
							if animation["ObjetcsCount"] > 9:
								Finish_Attack.emit()
								AnimatedSprite.play("Idle")
								Attacking = false
								animation["objects"] = []
								animation["ObjetcsCount"] = 0
								animation["NewObjectCountdown"] = 0.0
				else:
					animation["objects"] = []
					animation["ObjetcsCount"] = 0
					animation["NewObjectCountdown"] = 0.0
	Shield.visible = Protected > 0
	var DamageParticles: CPUParticles2D = SV.get_node(CurrentParticle)
	if DamagePartclesTimer > 0:
		DamageParticles.emitting = true
		DamagePartclesTimer -= delta
	else:
		DamageParticles.emitting = false
	if ReturnToIdle <= 0 and AnimatedSprite.animation != "Idle" and AnimatedSprite.animation != "Dead" and not Attacking:
		finish_animation()
	else:
		ReturnToIdle -= delta

func Start_Particles(Type: String, time: float = 0.4):
	if SV.get_node(Type):
		SV.get_node(CurrentParticle).emitting = false
		CurrentParticle = Type
		DamagePartclesTimer = time

func Start_anmation(Anim:String, time:float = 1):
	if AnimatedSprite.sprite_frames.get_frame_count(Anim) > 0:
		ReturnToIdle = time
		AnimatedSprite.play(Anim)
	else:
		if Anim == "Dying":
			AnimatedSprite.play("Dead")
		else:
			AnimatedSprite.play("Idle")

func finish_animation():
	if AnimatedSprite.animation == "Dying":
		AnimatedSprite.play("Dead")
	else:
		AnimatedSprite.play("Idle")

func Take_damage(Damage: int):
	HP = max(min(HP - Damage, Calcolate_Stat("HP")), 0)
	LifeBar.value = HP
	if Damage > 0:
		Play_Sound("Hit")
		SV.get_node("DamageText").Start(str(Damage), Color(1,0,0))
	else:
		Play_Sound("Heal")
		SV.get_node("DamageText").Start(str(-Damage), Color(0,1,0))
	if HP <= 0:
		DIE()

func Gain_EXP(EXP_gain: int):
	if Level == Team.LevCap:
		return true
	EXP += EXP_gain
	Check_Level_Up()
	return false

func Check_Level_Up():
	while EXP >= Get_Level_Up_EXP():
		EXP -= Get_Level_Up_EXP()
		Level_up()
		if Level == Team.LevCap:
			return

func Level_up():
	Level += 1
	LifeBar.max_value = Calcolate_Stat("HP")
	var NewMoves = Calcolate_Learnable_Moves()
	if Current_Moves.size() < 4 and NewMoves.size() > 0:
		for move in NewMoves:
			Current_Moves.append(move)
			if Current_Moves.size() >= 4:
				break

func Calculate_dropped_EXP(victory_character_level, team_size):
	var A = round((Data.Character_Data[Character_type]["Exp"] * Level / 5) * (1.5 / team_size) * max(0.5, 2 - sqrt(victory_character_level / Level)) + 1)
	return A

func Get_Level_Up_EXP() -> int:
	return Level * Level * Level

func Calcolate_Stats():
	var Stats = ["HP", "ATT", "PI", "DIF", "INT", "SPEED"]
	var Calcolated_stats = {}
	for Stat in Stats:
		Calcolated_stats[Stat] = Calcolate_Stat(Stat)
	return Calcolated_stats

func Calcolate_Stat(Stat: String) -> int:
	var Base_Stat = Data.Character_Data[Character_type]["Stats"][Stat]
	if Stat == "HP":
		var Molt = 2 if Boss else 1
		return int(Base_Stat / 50 * Level + Level + 10) * Molt
	else:
		var modificatore = StatModificMoltp[int(StatModific[Stat])]
		for s in Status:
			if "Stat" in StatusData[s] and Stat in StatusData[s]["Stat"]:
				modificatore *= StatusData[s]["Stat"][Stat]
		return int((Base_Stat / 50.0 * Level + 5) * modificatore)


func Calcolate_Learnable_Moves():
	var AddedMoves = []
	for Level_for_move in Data.Character_Data[Character_type]["Moves"]:
		if int(Level_for_move) <= Level:
			for Move in Data.Character_Data[Character_type]["Moves"][Level_for_move]:
				if not Move in Learnable_Moves:
					Learnable_Moves.append(Move)
					AddedMoves.append(Move)
	return AddedMoves

func assign_moves():
	if Learnable_Moves.size() <= 4:
		Current_Moves = Learnable_Moves.slice(0, Learnable_Moves.size())
	else:
		var selected_indices = []
		Current_Moves.clear()
		while Current_Moves.size() < 4:
			var random_index = randi_range(0, Learnable_Moves.size() - 1)
			if random_index not in selected_indices:
				selected_indices.append(random_index)
				Current_Moves.append(Learnable_Moves[random_index])

func GetUsableMoves():
	var UsableMoves = []
	for move in Current_Moves:
		if Energy >= Data.Move_data[move]["Energy"]:
			UsableMoves.append(move)
	return UsableMoves

func AI(AILevel: int = 0):
	var UsableMoves = GetUsableMoves()
	if UsableMoves.size() == 0:
		return ["Skip"]
	match AILevel:
		0:
			var Move
			if "Repeat" in Status:
				if LastMoveUsed in UsableMoves:
					Move = LastMoveUsed
				else:
					return ["Skip"]
			else:
				Move = UsableMoves.pick_random()
			var PlayerTeam = get_parent().PlayerTeam
			var Target
			match Data.Move_data[Move]["Target"]:
				"Enemy":
					Target = PlayerTeam.pick_random()
					while Target.Faint or Target == self:
						Target = PlayerTeam.pick_random()
				"All":
					Target = PlayerTeam
				"Self":
					Target = self
			return [Move, Target]

signal Waiting_for_dialogues()

func Turn():
	if Faint:
		await get_tree().create_timer(0.01).timeout
		get_parent().Finish_Turn.emit()
		return
	for s in Status:
		if "Skip" in StatusData[s]:
			if randf() <= StatusData[s]["Skip"] / 100:
				Start_Particles(s)
				await get_tree().create_timer(0.01).timeout
				get_parent().TextUpdate(Character_type + " can't do things becouse " + Character_type +" have " + s)
				await get_parent().Enter
				get_parent().Finish_Turn.emit()
				return
	var Move_and_Target = [null, null]
	if IsEnemy:
		Move_and_Target = AI()
		if Move_and_Target[0] == "Skip":
			Play_Sound("Sleep")
			Start_anmation("Nap", 1.5)
			await get_tree().create_timer(0.01).timeout
			get_parent().TextUpdate(Character_type + " decides to take a nap")
			await get_parent().Enter
			Energy = min(Energy + Data.Character_Data[Character_type]["EnergiaRegeneration"] * 2, MaxEnergy)
			get_parent().Finish_Turn.emit()
			return
	else:
		get_parent().TextUpdate("What move should " + Character_type + " use??")
		Move_and_Target[0] =  await get_parent().Get_move_from_player_input(self)
		if Move_and_Target[0] == "Skip":
			Play_Sound("Sleep")
			Start_anmation("Nap", 2.5)
			await get_tree().create_timer(0.01).timeout
			get_parent().TextUpdate(Character_type + " decides to take a nap")
			await get_parent().Enter
			Energy = min(Energy + Data.Character_Data[Character_type]["EnergiaRegeneration"] * 2, MaxEnergy)
			get_parent().Finish_Turn.emit()
			return
		if  Data.Move_data[Move_and_Target[0]]["Target"] == "All":
			Move_and_Target[1] = get_parent().EnemyTeam
		elif Data.Move_data[Move_and_Target[0]]["Target"] == "Enemy":
			Move_and_Target[1] =  await get_parent().Get_target_from_player_input()
		else:
			Move_and_Target[1] = self
	Energy -= Data.Move_data[Move_and_Target[0]]["Energy"]
	if Move_and_Target[1] is Array:
		for Enemy in Move_and_Target[1]:
			if not Enemy.Faint:
				Use_Move(Move_and_Target[0], Enemy)
				await Waiting_for_dialogues
	else:
		Use_Move(Move_and_Target[0], Move_and_Target[1])
		await Waiting_for_dialogues
	Energy = min(Energy + Data.Character_Data[Character_type]["EnergiaRegeneration"], MaxEnergy)
	get_parent().Finish_Turn.emit()

func Play_Sound(Sound:String):
	var Audio = get_node(Sound)
	if Audio:
		Audio.play()

func Play_Specific_sound(Sound:String):
	var Audio = AudioStreamPlayer.new()
	Audio.stream = load(Sound)
	add_child(Audio)
	Audio.play()
	await  Audio.finished
	Audio.queue_free()

func AddStatus(S, data = null):
	Status[S] = data
	Start_Particles(S)
	UpdateEffectsIcon()

func SetupAttackAnimation():
	Attacking = true
	if "Sound" in animation:
		Play_Specific_sound(animation["Sound"])
	if "CharacterAnimation" in animation:
		if not AnimatedSprite.sprite_frames.has_animation(animation["CharacterAnimation"]["AnimName"]):
			AnimatedSprite.sprite_frames.add_animation(animation["CharacterAnimation"]["AnimName"])
			for Frame in File.get_files_in_directory(animation["CharacterAnimation"]["Sprites"]):
				if Frame.get_extension() == "png":
					AnimatedSprite.sprite_frames.add_frame(animation["CharacterAnimation"]["AnimName"], load(animation["CharacterAnimation"]["Sprites"] + "/" + Frame))
			if "FPS" in animation["CharacterAnimation"]:
				AnimatedSprite.sprite_frames.set_animation_speed(animation["CharacterAnimation"]["AnimName"], animation["CharacterAnimation"]["FPS"])
		AnimatedSprite.play(animation["CharacterAnimation"]["AnimName"])
	match  animation["Type"]:
		pass

func Use_Move(Move: String, Target: CharacterData):
	LastMoveUsed = Move 
	get_parent().TextUpdate(Character_type + " use " + Move + " on " + Target.Character_type + "!!!")
	await get_parent().Enter
	var AdditionalChance = 0
	if "ChanceScript" in Data.Move_data[Move]:
		var script = load("res://Scripts/Chance Scripts/" +  Data.Move_data[Move]["ChanceScript"] +".gd").new()
		add_child(script)
		AdditionalChance += script.script(self, Target, Move)
		script.queue_free()
	if randf() < (Data.Move_data[Move]["Chance"] + AdditionalChance) / 100:
		if Data.Move_data[Move]["Move type"] == "Fisica" and "Angry" in Status:
			Start_Particles("Angry")
		AttTarget = Target
		if  "Animation" in Data.Move_data[Move]:
			animation = Data.Move_data[Move]["Animation"]
			SetupAttackAnimation()
			await Finish_Attack
		elif Data.Move_data[Move]["Move type"] != "Status":
			animation = {
				"Type": "Follow",
				"Speed": 0.2
				}
			SetupAttackAnimation()
			await Finish_Attack
		if Target != self and Target.IsEnemy != IsEnemy and Target.Protected > 0:
			Target.Play_Sound("Shield")
			await get_tree().create_timer(0.01).timeout
			get_parent().TextUpdate("But " + Target.Character_type + "  protected!")
			await get_parent().Enter
		else:
			if Data.Move_data[Move]["Move type"] != "Status":
				var Texts = []
				var power = Data.Move_data[Move]["Power"]
				var attack = Calcolate_Stat("ATT") if Data.Move_data[Move]["Move type"] == "Fisica" else Calcolate_Stat("PI")
				var defens = Target.Calcolate_Stat("DIF")
				var stab = 1.5 if Data.Move_data[Move]["Type"] in Data.Character_Data[Character_type]["Types"] else 1.0
				var type_bonus = 1.0
				for type in Data.Character_Data[Target.Character_type]["Types"]:
					if Data.Move_data[Move]["Type"] in Data.Type_data[type]["Effectiveness"]:
						type_bonus *= Data.Type_data[type]["Effectiveness"][Data.Move_data[Move]["Type"]]
				if type_bonus == 0:
					Texts.append("It has no effect")
				elif type_bonus > 1:
					Texts.append("IT HURTS")
				elif type_bonus < 1:
					Texts.append("He didn't do anything special to him")
				var damage = (((2 * Level / 5.0 + 2) * power * attack / defens) / 50.0 + 2) * stab * type_bonus * randf_range(0.9,1.1)
				if randf() < 0.05:
					damage *= 2
					Texts.append("CRITICAL HIT")
				Target.Take_damage(max(1, round(damage)))
				for text in Texts:
					await get_tree().create_timer(0.01).timeout
					get_parent().TextUpdate(text)
					await get_parent().Enter
			if "Script" in Data.Move_data[Move]:
				var Index = 0
				for ScriptData in Data.Move_data[Move]["Script"]:
					var script = load("res://Scripts/Move Scripts/"+ ScriptData["Script"] +".gd").new()
					add_child(script)
					script.script(self, Target, Move, Index)
					script.queue_free()
					Index += 1
			if "Stat" in Data.Move_data[Move]:
				for Stat in Data.Move_data[Move]["Stat"]:
					var ThisTarget: CharacterData
					if Stat["Target"] == "Self":
						ThisTarget = self
					else:
						ThisTarget = Target
					if ThisTarget.StatModific[Stat["Stat"]] == 6 or ThisTarget.StatModific[Stat["Stat"]] == -6:
						await get_tree().create_timer(0.01).timeout
						get_parent().TextUpdate(Stat["Stat"] + " of " + ThisTarget.Character_type + "  can no longer increase")
						await get_parent().Enter
					else:
						ThisTarget.StatModific[Stat["Stat"]] = max(min(ThisTarget.StatModific[Stat["Stat"]] +  Stat["Power"], 6), -6)
						await get_tree().create_timer(0.01).timeout
						var PlusOrMinus: String
						if Stat["Power"] < 0:
							PlusOrMinus = " decrease!!"
							ThisTarget.Start_Particles("LowerStat")
							ThisTarget.Play_Sound("LowerStatS")
						else:
							PlusOrMinus = " increases!!"
							ThisTarget.Start_Particles("UpperStat")
							ThisTarget.Play_Sound("UpperStatS")
						get_parent().TextUpdate(Stat["Stat"] + " of " + ThisTarget.Character_type + PlusOrMinus)
						await get_parent().Enter
			if "Status" in Data.Move_data[Move]:
				for Statuss in Data.Move_data[Move]["Status"]:
					if randf() <= Data.Move_data[Move]["Status"][Statuss]["Chance"] / 100:
						Target.AddStatus(Statuss ,Data.Move_data[Move]["Status"][Statuss]["Data"])  
						await get_tree().create_timer(0.01).timeout
						get_parent().TextUpdate(Target.Character_type + " now has " + Statuss)
						await get_parent().Enter
			if "Effect" in Data.Move_data[Move]:
				for Effect in  Data.Move_data[Move]["Effect"]:
					match Effect:
						"Protected":
							if Data.Move_data[Move]["Effect"]["Protected"]["Target"] == "Target":
								Target.Protected += Data.Move_data[Move]["Effect"]["Protected"]["Time"]
							else:
								Protected += Data.Move_data[Move]["Effect"]["Protected"]["Time"]
	else:
		Start_anmation("Fail", 1.5)
		Play_Sound("Fail")
		Start_Particles("Failed") 
		await get_tree().create_timer(0.01).timeout
		get_parent().TextUpdate("But he Failed")
		await get_parent().Enter
		if randf() <= 0.1:
			AddStatus("Angry")
			await get_tree().create_timer(0.01).timeout
			get_parent().TextUpdate(Character_type + " now has Angry")
			await get_parent().Enter
	Waiting_for_dialogues.emit()
