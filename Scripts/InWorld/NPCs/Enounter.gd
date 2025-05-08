extends CharacterBody3D
class_name Encounter

const MIN_PLAYER_DISTANT = 1
const MIN_PLAYER_DISTANT_TO_FOLLOW = 10

var Squad: Array[CharacterData]
var Sprite_Frames: SpriteFrames
var Sprite := AnimatedSprite3D.new()

func _init(Spawn_Pool: SpawnPool):
	Sprite_Frames = Spawn_Pool.World_Sprite
	var CharacterList: Array[String] = []
	for character in Spawn_Pool.Spawn_Pool:
		for i in range(character.Weight):
			CharacterList.append(character.Type)
	var MaxLevel = Team.Get_max_level()
	for i in range(randi_range(1,4)):
		var NewCharacter = CharacterData.new(CharacterList.pick_random(), round(MaxLevel * randf_range(0.7,1)))
		Squad.append(NewCharacter)

func _ready():
	Sprite.sprite_frames = Sprite_Frames
	Sprite.rotation.x = deg_to_rad(-15)
	Sprite.play("Idle")
	add_child(Sprite)
	var Collision = CollisionShape3D.new()
	var Shape = CapsuleShape3D.new()
	Shape.radius =  1
	Shape.height = 1
	Collision.shape = Shape
	add_child(Collision)
	add_to_group("Encounter")

func Get_Player_Distant():
	var player: Player = get_tree().get_first_node_in_group("Player")
	return player.global_position.distance_to(global_position)

func _process(delta):
	if Team.Pause:
		return
	if Get_Player_Distant() <= MIN_PLAYER_DISTANT:
		Team.StartBattle(Squad)
		await Team.FinishedBattle
		queue_free()

func _physics_process(delta):
	if Team.Pause:
		return
	if not is_on_floor():
		velocity.y -= 0.098
	if Get_Player_Distant() <= MIN_PLAYER_DISTANT_TO_FOLLOW:
		global_position = lerp(global_position, get_tree().get_first_node_in_group("Player").global_position, 0.01)
	move_and_slide()
