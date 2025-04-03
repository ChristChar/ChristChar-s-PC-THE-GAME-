extends Area2D
class_name CharacterData

# Variabili del personaggio
var Character_type: String = "Gino"
var CurrentParticle = "Damage"
var Level = 5
var EXP = 0
var Original_ZIndex: int
var DamagePartclesTimer = 0
var ReturnToIdle = 0
var Energy = 0
var MaxEnergy = 0
var HP: int
var StartPosition: Vector2
var Current_Moves = []
var Learnable_Moves = []
var StatModific = {"HP":0,"ATT":0,"DIF":0,"PI":0,"INT":0,"SPEED":0}
var IsEnemy = false
var Faint = false
var Focus = false
var Attacking = false
var AttTarget: CharacterData
var animation: Dictionary

var LifeBar := ProgressBar.new()
var AnimatedSprite := AnimatedSprite2D.new()

const HealthBar = "res://Scenes/BarraDellaVita.tscn"
const Particles = {
	"Damage":"res://Scenes/Particles/Damage.tscn",
	"Failed":"res://Scenes/Particles/Failed.tscn"
}
const Animations = ["Idle","Dead","Fail", "Dying"]
const  Audios = {
	"Hit":  "res://Resources/Sounds/Hit.mp3",
	"Fail": "res://Resources/Sounds/Fail.mp3",
	"Dead": "res://Resources/Sounds/DeathBong.mp3"
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

signal Finish_Attack()

func _init(type, level:int = 10):
	MaxEnergy = Data.Character_Data[Character_type]["MaxEnergia"]
	if type is CharacterSave:
		Level = type.Level
		Character_type = type.Character_type
		HP = type.HP
		EXP = type.EXP
		Current_Moves = type.Current_Moves
		Learnable_Moves = type.Learnable_Moves
		Energy = type.Energy
		Faint = type.Faint
	else:
		Character_type = type
		Level = level
		Calcolate_Learnable_Moves()
		HP = Calcolate_Stat("HP")
		if Current_Moves == []:
			assign_moves()
		Energy = MaxEnergy

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
	var NewShape = CollisionShape2D.new()
	var Shape = RectangleShape2D.new()
	Shape.size = Vector2(300, 300)
	NewShape.shape = Shape
	add_child(NewShape)
	# Configurazione AnimatedSprite2D
	var NewFrames = SpriteFrames.new()
	for animation in Animations:
		var Path = "res://Resources/Images/Characters/" + Character_type + "/" + animation
		NewFrames.add_animation(animation)
		for Frame in File.get_files_in_directory(Path):
			if Frame.get_extension() == "png":
				NewFrames.add_frame(animation, load(Path + "/" + Frame))
		if Character_type in Data.Specific_Animations and animation in Data.Specific_Animations[Character_type]:
			if "Loop" in Data.Specific_Animations[Character_type][animation]:
				NewFrames.set_animation_loop(animation,Data.Specific_Animations[Character_type][animation]["Loop"])
			if "Framerate" in Data.Specific_Animations[Character_type][animation]:
				NewFrames.set_animation_speed(animation, Data.Specific_Animations[Character_type][animation]["Framerate"])
	AnimatedSprite.sprite_frames = NewFrames
	if IsEnemy:
		AnimatedSprite.flip_h = true
	AnimatedSprite.name = "AnimatedSprite"
	add_child(AnimatedSprite)
	AnimatedSprite.play("Idle")

	# Configurazione barra della vita
	LifeBar = load(HealthBar).instantiate()
	LifeBar.position = Vector2(-140, -175)
	LifeBar.max_value = HP
	add_child(LifeBar)
	
	#Configurazione particles
	for Particle in Particles:
		var NewParticle = load(Particles[Particle]).instantiate()
		NewParticle.name = Particle
		add_child(NewParticle)
	
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
	Original_ZIndex = z_index

func Info():
	get_parent().Change_info(self)
	if not Faint and get_parent().Selecting_Target:
		FocusSwitch(true)

func Not_Info():
	FocusSwitch(false)

func FocusSwitch(on:bool):
	var color = Color(0.9, 0.9, 0.9, 0.6) if on else Color(1, 1, 1)
	modulate = color
	Focus = on

func DIE():
	FocusSwitch(false)
	Faint = true
	LifeBar.visible = false
	Start_anmation("Dying", 1)
	Play_Sound("Dead")

func Reset():
	HP = Calcolate_Stat("HP")
	Faint = false
	StatModific = {"HP":0,"ATT":0,"DIF":0,"PI":0,"INT":0,"SPEED":0}
	LifeBar.visible = true
	LifeBar.value = Calcolate_Stat("HP")
	AnimatedSprite.play("Idle")
	Energy = MaxEnergy

func _process(delta):
	if Focus and get_parent().Selecting_Target:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			get_parent().Selected_Target = self
	if Attacking:
		match animation["Type"]:
			"Follow":
				if global_position.distance_to(AttTarget.global_position) < 10:
					Attacking = false
					AttTarget.Start_Particles("Damage")
					AttTarget.Play_Sound("Hit")
					global_position = StartPosition
					AnimatedSprite.play("Idle")
					z_index = Original_ZIndex
					Finish_Attack.emit()
				else:
					global_position = lerp(global_position, AttTarget.global_position, animation["Speed"])
			"ThrowObject":
				if $Object:
					if $Object.global_position.distance_to(AttTarget.global_position) < 10:
						Attacking = false
						AttTarget.Start_Particles("Damage")
						AttTarget.Play_Sound("Hit")
						$Object.queue_free()
						AnimatedSprite.play("Idle")
						Finish_Attack.emit()
					else:
						$Object.global_position = lerp($Object.global_position, AttTarget.global_position, animation["Speed"])
						if animation["Spinning"]:
							$Object.rotation += 15
				else:
					var NewObject = Sprite2D.new()
					NewObject.texture = load(animation["Sprite"])
					NewObject.name = "Object"
					NewObject.z_index = 3
					add_child(NewObject)
			"Laser":
				if $Object:
					if $Object.get_point_position(1).distance_to($Object.to_local(AttTarget.global_position)) < 10:
						Attacking = false
						AttTarget.Start_Particles("Damage")
						AttTarget.Play_Sound("Hit")
						$Object.queue_free()
						AnimatedSprite.play("Idle")
						Finish_Attack.emit()
					else:
						var LinePosition = $Object.get_point_position(1)
						$Object.clear_points()
						$Object.add_point(Vector2(0,0))
						$Object.add_point(lerp(LinePosition,$Object.to_local(AttTarget.global_position), 0.15))
				else:
					var NewObject = Line2D.new()
					NewObject.name = "Object"
					NewObject.width = animation["Width"]
					NewObject.default_color = File.RGB_to_color(animation["Color"])
					NewObject.z_index = 5
					add_child(NewObject)
					$Object.add_point(Vector2(0,0))
					$Object.add_point(Vector2(0,0))
			"ExpandingCircle":
				if $Object:
					if $Object.radius >= 750:
						Attacking = false
						$Object.queue_free()
						AnimatedSprite.play("Idle")
						AttTarget.Start_Particles("Damage")
						AttTarget.Play_Sound("Hit")
						Finish_Attack.emit()
					else:
						$Object.radius += animation["Speed"] * delta
				else:
					var NewObject = MeshInstance2D.new()
					var circle_mesh = CylinderMesh.new()
					circle_mesh.bottom_radius = 1.0
					circle_mesh.top_radius = 1.0
					circle_mesh.height = 0.1
					circle_mesh.radial_segments = 32
					NewObject.name = "Object"
					NewObject.position = AttTarget.global_position
					NewObject.z_index = 4
					add_child(NewObject)

	var DamageParticles: CPUParticles2D = get_node(CurrentParticle)
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
	get_node(CurrentParticle).emitting = false
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
	if HP <= 0:
		DIE()

func Gain_EXP(EXP_gain: int):
	EXP += EXP_gain
	Check_Level_Up()

func Check_Level_Up():
	while EXP >= Get_Level_Up_EXP():
		EXP -= Get_Level_Up_EXP()
		Level_up()

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
		return int(Base_Stat / 50 * Level + Level + 10)
	else:
		var modificatore = StatModificMoltp[int(StatModific[Stat])]
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

func AI(AILevel: int = 0):
	var UsableMoves = []
	for move in Current_Moves:
		if Energy >= Data.Move_data[move]["Energy"]:
			UsableMoves.append(move)
	if UsableMoves.size() == 0:
		return ["Skip"]
	match AILevel:
		0:
			var PlayerTeam = get_parent().PlayerTeam
			var Target = PlayerTeam.pick_random()
			while Target.Faint:
				Target = PlayerTeam.pick_random()
			return [UsableMoves.pick_random(), Target]

signal Waiting_for_dialogues()

func Turn():
	if Faint:
		await get_tree().create_timer(0.01).timeout
		get_parent().Finish_Turn.emit()
		return
	var Move_and_Target = [null, null]
	if IsEnemy:
		Move_and_Target = AI()
		if Move_and_Target[0] == "Skip":
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
			await get_tree().create_timer(0.01).timeout
			get_parent().TextUpdate(Character_type + " decides to take a nap")
			await get_parent().Enter
			Energy = min(Energy + Data.Character_Data[Character_type]["EnergiaRegeneration"] * 2, MaxEnergy)
			get_parent().Finish_Turn.emit()
			return
		if "Target" in Data.Move_data[Move_and_Target[0]] and Data.Move_data[Move_and_Target[0]]["Target"] == "All":
			Move_and_Target[1] = get_parent().EnemyTeam
		elif "Has Target" in Data.Move_data[Move_and_Target[0]] or Data.Move_data[Move_and_Target[0]]["Move type"] != "Status":
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
		"Follow":
			z_index = 20

func Use_Move(Move: String, Target: CharacterData):
	get_parent().TextUpdate(Character_type + " use " + Move + " on " + Target.Character_type + "!!!")
	await get_parent().Enter
	if randf() < Data.Move_data[Move]["Chance"] / 100:
		if Data.Move_data[Move]["Move type"] != "Status":
			var power = Data.Move_data[Move]["Power"]
			var attack = Calcolate_Stat("ATT") if Data.Move_data[Move]["Move type"] == "Fisica" else Calcolate_Stat("PI")
			var defens = Target.Calcolate_Stat("DIF")
			var stab = 1.5 if Data.Move_data[Move]["Type"] in Data.Character_Data[Character_type]["Types"] else 1.0
			var type_bonus = 1.0
			for type in Data.Character_Data[Target.Character_type]["Types"]:
				if Data.Move_data[Move]["Type"] in Data.Type_data[type]["Effectiveness"]:
					type_bonus *= Data.Type_data[type]["Effectiveness"][Data.Move_data[Move]["Type"]]
			if type_bonus == 0:
				await get_tree().create_timer(0.01).timeout
				get_parent().TextUpdate("It has no effect")
				await get_parent().Enter
			elif type_bonus > 1:
				await get_tree().create_timer(0.01).timeout
				get_parent().TextUpdate("IT HURTS")
				await get_parent().Enter
			elif type_bonus < 1:
				await get_tree().create_timer(0.01).timeout
				get_parent().TextUpdate("He didn't do anything special to him")
				await get_parent().Enter
			if  "Animation" in Data.Move_data[Move]:
				animation = Data.Move_data[Move]["Animation"]
			else:
				animation = {
					"Type": "Follow",
					"Speed": 0.2
				}
			SetupAttackAnimation()
			AttTarget = Target
			await Finish_Attack
			var damage = (((2 * Level / 5.0 + 2) * power * attack / defens) / 50.0 + 2) * stab * type_bonus * randf_range(0.9,1.1)
			if randf() < 0.05:
				damage *= 2
				await get_tree().create_timer(0.01).timeout
				get_parent().TextUpdate("CRITICAL HIT")
				await get_parent().Enter
			Target.Take_damage(max(1, round(damage)))
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
				if Target.StatModific[Stat["Stat"]] == 6 or Target.StatModific[Stat["Stat"]] == -6:
					await get_tree().create_timer(0.01).timeout
					get_parent().TextUpdate(Stat["Stat"] + " of " + Target.Character_type + "  can no longer increase")
					await get_parent().Enter
				else:
					Target.StatModific[Stat["Stat"]] = max(min(Target.StatModific[Stat["Stat"]] +  Stat["Power"], 6), -6)
					await get_tree().create_timer(0.01).timeout
					var PlusOrMinus: String
					if Stat["Power"] < 0:
						PlusOrMinus = " decrease!!"
					else:
						PlusOrMinus = " increases!!"
					get_parent().TextUpdate(Stat["Stat"] + " of " + Target.Character_type + PlusOrMinus)
					await get_parent().Enter
	else:
		Start_anmation("Fail", 1.5)
		Play_Sound("Fail")
		Start_Particles("Failed")
		await get_tree().create_timer(0.01).timeout
		get_parent().TextUpdate("But he Failed")
		await get_parent().Enter
	Waiting_for_dialogues.emit()
