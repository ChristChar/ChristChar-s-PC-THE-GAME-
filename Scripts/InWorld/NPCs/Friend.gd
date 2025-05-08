extends CharacterBody3D
class_name Friend

@export var Teamate: int = 1
var AnimatedSprite := AnimatedSprite3D.new()
var Go_To = Vector3(randf_range(-1,1), 0, randf_range(-1,1))

func _ready():
	add_to_group("Friend")
	set_collision_layer_value(1, false)
	set_collision_layer_value(2, true)
	set_collision_mask_value(2, true)
	ChangeAnimatedSprite()
	AnimatedSprite.rotation.x = deg_to_rad(-15)
	AnimatedSprite.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	add_child(AnimatedSprite)
	var Collision = CollisionShape3D.new()
	var Shape = CapsuleShape3D.new()
	Shape.height = 1.25
	Shape.radius = 0.8
	Collision.shape = Shape
	add_child(Collision)
	var timer = Timer.new()
	timer.wait_time = 2
	add_child(timer)
	timer.connect("timeout", Randomize_The_thing)
	timer.start()

func Randomize_The_thing():
	Go_To = Vector3(randf_range(-1,1), 0, randf_range(-1,1))

func _process(delta):
	if global_position.distance_to(get_tree().get_first_node_in_group("Player").global_position + Go_To) > 1:
		AnimatedSprite.play("Walk")
	else:
		AnimatedSprite.play("Idle")
	AnimatedSprite.flip_h =  get_tree().get_first_node_in_group("Player").global_position < global_position

func ChangeAnimatedSprite():
	if Team.team.size() > Teamate:
		AnimatedSprite.sprite_frames = load("res://Data/CharacterInWordlSpriteFrames/" + Team.team[Teamate].Character_type + ".tres")
		AnimatedSprite.scale = Vector3(128.0 /  AnimatedSprite.sprite_frames.get_frame_texture("Idle", 0).get_width() ,128.0 /  AnimatedSprite.sprite_frames.get_frame_texture("Idle", 0).get_height(),1)

func _physics_process(delta):
	var gravity = Vector3.DOWN * 9.8  # Accelera la gravità
	velocity += gravity * delta
	if global_position.distance_to(get_tree().get_first_node_in_group("Player").global_position) > 1:
		var player : Player = get_tree().get_first_node_in_group("Player")
		if player:
			var direction = (player.global_position + Go_To - global_position ).normalized() # Imposta la velocità desiderata
			var speed = 3.25
			if Input.is_key_pressed(KEY_SHIFT):
				speed *= 2
			velocity = direction * speed
	move_and_slide()
