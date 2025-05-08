extends Node3D
class_name Map

@export var EnemyCount: int = 40
@export var SpaenPool: Dictionary[String, SpawnPool]
@export var Music: AudioStream
@export var BattleBackground: Texture2D
@export var SpawnRange: int = 50
@export var Camera_fov: float = 75.0

func _ready():
	call_deferred("SpawnEncounetrs")

func SpawnEncounetrs():
	for i in range(EnemyCount):
		var NewEncounter = Encounter.new(SpaenPool["Virus"])
		NewEncounter.global_position = Vector3(randi_range(-SpawnRange,SpawnRange),2,randi_range(-SpawnRange,SpawnRange))
		add_child(NewEncounter)
