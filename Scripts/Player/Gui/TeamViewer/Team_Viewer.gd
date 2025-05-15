extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		visible = false


func _on_gestisci_mosse_pressed():
	$GestisciMosse.Open($Info.Current_character)
