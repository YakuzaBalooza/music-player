extends VBoxContainer

@onready var panel = $"../.."
@onready var blur = $"../../../ColorRect"
var out : bool = false
var x : float = 0.0
var b : float = 0.0

func _on_options_pressed() -> void:
	if out:
		x = -358
		out = false
		b = 0.0
	else:
		x = 0.0
		out = true
		b = 1.5
	var tween = get_tree().create_tween()
	tween.tween_property(
		panel,
		"position",
		Vector2(x,panel.position.y),
		.1).set_trans(Tween.TRANS_LINEAR)
	blur.blur(b)
