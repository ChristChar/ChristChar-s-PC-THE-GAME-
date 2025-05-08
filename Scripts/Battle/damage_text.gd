extends CPUParticles2D

func Start(Text: String, color:Color = Color(1,0,0)):
	emitting = true
	$SubViewport/Label.text = Text
	$SubViewport/Label.add_theme_color_override("font_color", color)
