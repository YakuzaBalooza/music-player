extends VBoxContainer

signal delete_playlist
signal load_playlist(s: Array[String])

@onready var buttons = $ScrollContainer/Buttons
@onready var nameedit = $NameEdit

##The Resource to use for this playlist.
var res : PlaylistData
##The path to res.
var path : String

func setup(p: String) -> void:
	path = p
	res = ResourceLoader.load(path)
	name = res.Name
	nameedit.text = res.Name
	make_buttons()

func make_buttons() -> void:
	for c in buttons.get_children():
		c.queue_free()
	var i = 0
	for s in res.Songs:
		var spawn = load("res://Scenes/playlist_song.tscn")
		var inst = spawn.instantiate()
		buttons.add_child(inst)
		inst.setup(s.left(-4), i)
		inst.connect("remove_song", remove_song)
		i += 1
	i = 0

func remove_song(s: String):
	res.Songs.erase(s + '.mp3')
	ResourceSaver.save(res, path)

func _on_delete_pressed() -> void:
	delete_playlist.emit()

func _on_name_edit_text_changed() -> void:
	res.Name = nameedit.text
	ResourceSaver.save(res, path)
	name = res.Name

func _on_add_songs_pressed() -> void:
	var dialog = FileDialog.new()
	dialog.set_file_mode(FileDialog.FILE_MODE_OPEN_FILES)
	dialog.set_access(FileDialog.ACCESS_FILESYSTEM)
	dialog.set_use_native_dialog(true)
	dialog.connect("files_selected", add_songs)
	dialog.current_path = path
	add_child(dialog)
	dialog.popup_centered_ratio()

func add_songs(s: Array[String]):
	for p in s:
		res.Songs.append(p)
	ResourceSaver.save(res, path)
	make_buttons()

func _on_load_pressed() -> void:
	load_playlist.emit(res.Songs)
