extends Node3D
class_name Map

@export var EnemyCount: int = 40
@export var SpaenPool: Dictionary[String, SpawnPool]
@export var Music: AudioStream
@export var BattleBackground: Texture2D

func _ready():
	call_deferred("SpawnEncounetrs")
	
func SpawnEncounetrs():
	for i in range(EnemyCount):
		var NewEncounter = Encounter.new(SpaenPool["Virus"])
		NewEncounter.global_position = Vector3(randi_range(-50,50),2,randi_range(-50,50))
		add_child(NewEncounter)
