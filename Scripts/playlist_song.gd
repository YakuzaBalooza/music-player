extends Control

signal remove_song(String)

@onready var label = $MarginContainer/Label
var id: int
var path: String

func setup(n: String, i: int) -> void:
	path = n
	var o = n.reverse()
	var x = o.find("/")
	o = o.left(x).reverse()
	label.text = o
	id = i

func _on_button_2_pressed() -> void:
	remove_song.emit(path)
	queue_free()
