extends Control

signal load_playlist(s: Array[String])

@onready var tab = $VBoxContainer/TabContainer

##Array of paths to playlist datas.
var playlists : Array[String]

func _ready() -> void:
	setup()

func setup() -> void:
	find_playlists()
	make_pages()

func find_playlists() -> void:
	for f in DirAccess.get_files_at("user://playlists/"):
		if f.ends_with('.tres'):
			playlists.append("user://playlists/" + f)

func make_pages() -> void:
	var i = 0
	for p in playlists:
		spawn_page(i)
		i += 1
	i = 0

func spawn_page(i: int) -> void:
	var spawn = load("res://Scenes/playlist_page.tscn")
	var inst = spawn.instantiate()
	tab.add_child(inst)
	inst.setup(playlists[i])
	inst.connect("delete_playlist", delete_page)
	inst.connect("load_playlist", load_songs)

func delete_page():
	DirAccess.remove_absolute(playlists[tab.current_tab])
	playlists.remove_at(tab.current_tab)
	tab.get_child(tab.current_tab).queue_free()

func _on_new_pressed() -> void:
	ResourceSaver.save(PlaylistData.new(),
	"user://playlists/" + str(playlists.size()) + ".tres")
	playlists.append("user://playlists/" + str(playlists.size()) + ".tres")
	spawn_page(playlists.size() - 1)

func load_songs(a: Array[String]):
	load_playlist.emit(a)
