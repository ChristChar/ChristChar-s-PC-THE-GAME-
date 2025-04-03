extends CharacterBody3D
class_name Player

const SPEED = 3.5

signal BattleAnimationFinished()

func _ready():
	ChangeAnimatedSprite()

func ChangeAnimatedSprite():
	$AnimatedSprite2D.sprite_frames = load("res://Data/CharacterInWordlSpriteFrames/" + Team.team[0].Character_type + ".tres")
	$AnimatedSprite2D.scale = Vector3(128.0 / $AnimatedSprite2D.sprite_frames.get_frame_texture("Idle", 0).get_width(), 128.0 / $AnimatedSprite2D.sprite_frames.get_frame_texture("Idle", 0).get_height(), 1)

func _process(delta):
	if velocity != Vector3.ZERO:
		$AnimatedSprite2D.play("Walk")
	else:
		$AnimatedSprite2D.play("Idle")

func ViewObtainedCharacter(Character: String):
	$CanvasLayer/CharacterObtained/PanelContainer/TextureRect.texture = load("res://Resources/Images/Characters/" + Character + "/Idle/1.png")
	$CanvasLayer/CharacterObtained/Label.text = "YOU OBTAIN " + Character
	$CanvasLayer/CharacterObtained.visible = true
	Team.Pause = true

func Battle_Start_Animation():
	$BattleStart.play()
	var initial_fov = $Camera3D.fov
	var target_fov_out = initial_fov * 1.5
	var target_fov_in = initial_fov * 0.5
	var steps = 50
	var delay = 0.007

	# Zoom out
	for i in range(steps):
		$Camera3D.fov = lerp(initial_fov, target_fov_out, float(i) / steps)
		await get_tree().create_timer(delay).timeout

	# Zoom in
	for i in range(steps):
		$Camera3D.fov = lerp(target_fov_out, target_fov_in, float(i) / steps)
		await get_tree().create_timer(delay).timeout

	BattleAnimationFinished.emit()
	$Camera3D.fov = initial_fov

func Reset():
	Team.Cure_team()
	get_parent().ReturnToMainMap("PlayerSpawn")
	for friend in get_tree().get_nodes_in_group("Friend"):
		friend.global_position = get_tree().get_first_node_in_group("PlayerSpawn").global_position + Vector3(randf_range(-1, 1),randf_range(-1, 1), randf_range(-1, 1))

func _physics_process(delta):
	if not Team.Pause:
		if not is_on_floor():
			velocity.y -= 0.098
		var Curent_speed = SPEED
		if Input.is_key_pressed(KEY_SHIFT):
			Curent_speed *= 2
		var directionX = Input.get_axis("ui_left", "ui_right")
		if directionX:
			velocity.x = directionX * Curent_speed
			$AnimatedSprite2D.flip_h = directionX < 0
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
		var directionZ = Input.get_axis("ui_up", "ui_down")
		if directionZ:
			velocity.z = directionZ * Curent_speed
		else:
			velocity.z = move_toward(velocity.z, 0, SPEED)

		move_and_slide()


func _on_ok_pressed():
	$CanvasLayer/CharacterObtained.visible = false
	Team.Pause = false
