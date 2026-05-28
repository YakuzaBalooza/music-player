extends Control

signal try_new_song(int)

@onready var label = $MarginContainer/Label
var id: int

func setup(n: String, i: int) -> void:
	label.text = n
	id = i

func _on_button_pressed() -> void:
	try_new_song.emit(id)

func _on_button_mouse_entered() -> void:
	label.modulate = Color.BLACK
func _on_button_mouse_exited() -> void:
	label.modulate = Color.WHITE
