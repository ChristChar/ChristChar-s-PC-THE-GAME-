extends Control

var text: String
var texture: Texture2D

func _ready():
	$Control/HBoxContainer/Label.text = text
	if texture:
		$Control/HBoxContainer/TextureRect.texture = texture
	$AnimationPlayer.play("Notific")
	await  $AnimationPlayer.animation_finished
	queue_free()
