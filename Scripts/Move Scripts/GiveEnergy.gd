extends Node

var Has_Target = true

func script(User:CharacterData,Target:CharacterData,Move:String,Index: int):
	if randf() < Data.Move_data[Move]["Script"][Index]["Chance"] / 100:
		var Value = (((2 * User.Level / 5.0 + 2) * Data.Move_data[Move]["Script"][Index]["Power"] * User.Calcolate_Stat("INT") / Target.Level) / 50.0 + 2) * randf_range(0.9,1.1)
		Target.Energy += round(Value)
		Target.Play_Sound("Heal")
