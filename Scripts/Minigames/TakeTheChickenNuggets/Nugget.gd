extends RigidBody2D
class_name Nugget

func _ready():
	var Sprite = Sprite2D.new()
	var texture = preload("res://Resources/Images/Minigames/TakeTheChickenNuggets/ChickenNugget.png")
	Sprite.texture = texture
	add_child(Sprite)
	var Collision = CollisionShape2D.new()
	var Shape = RectangleShape2D.new()
	Shape.size = texture.get_size()
	Collision.shape = Shape
	add_child(Collision)
