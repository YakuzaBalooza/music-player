extends ColorRect

func blur(b: float):
	var tween = get_tree().create_tween()
	tween.tween_property(
		self.material,
		'shader_parameter/blur_amount',
		b,
		.1)
