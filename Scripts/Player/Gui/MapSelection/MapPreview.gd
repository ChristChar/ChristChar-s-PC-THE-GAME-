extends Sprite2D

var scroll_speed: float = 15.0  # Velocità di scorrimento in pixel al secondo
var direction: int = 1  # 1 per destra, -1 per sinistra

func _process(delta):
	# Aggiorna l'offset della texture in base alla velocità e alla direzione
	position.x += scroll_speed * delta * direction

	# Calcola la larghezza dell'immagine e del TextureRect
	var texture_width = texture.get_size().x
	var rect_width = 360

	# Inverte la direzione se l'immagine raggiunge un'estremità
	if position.x >= (texture_width - rect_width) / 2:
		direction = -1
	elif  position.x <= -(texture_width - rect_width) / 2:
		direction = 1
