extends Node

func script(user:CharacterData,target:CharacterData,move:String):
	var base_chance = Data.Move_data[move]["Chance"]
	var level_diff = user.Level - target.Level  # positivo se user > target, negativo altrimenti

	# Se stessi allo stesso livello, nessuna variazione
	if level_diff == 0:
		return 0.0

	# Calcola un modificatore proporzionale alla differenza di livello
	# Puoi regolare il fattore (qui 0.05) per rendere l'effetto più o meno marcato
	var factor = 5
	var modifier = level_diff * factor

	# Opzionale: limita il modifier a un range, per non stravolgere la chance
	var min_mod = -base_chance    # non ridurre mai sotto -100% della chance base
	var max_mod = base_chance     # non aumentare mai sopra +100% della chance base
	modifier = clamp(modifier, min_mod, max_mod)

	return modifier
