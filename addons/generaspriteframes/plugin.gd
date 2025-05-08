# addons/my_exporter/plugin.gd
@tool
extends EditorPlugin

var exporter := preload("res://addons/generaspriteframes/Generatore.gd").new()

func _enter_tree() -> void:
	add_export_plugin(exporter)  
	print("A!")    # ← Qui lo registri :contentReference[oaicite:0]{index=0}

func _exit_tree() -> void:
	remove_export_plugin(exporter)
	print("A =(")
