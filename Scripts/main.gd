extends Control

@onready var audio = $AudioStreamPlayer
@onready var buttons = $HBox/Scroll/Buttons
@onready var nowplay = $HBox/Controls/NowPlaying
@onready var title = $HBox/Controls/Title
@onready var ctrlplay = $HBox/Controls/CtrlBtn/CtrlPlay
@onready var ctrlloop = $HBox/Controls/CtrlBtn/CtrlLoop
@onready var progress = $HBox/Controls/MarginContainer2/PlayProgress
@onready var timecur = $HBox/Controls/MarginContainer3/HBoxContainer/TimeCur
@onready var timelen = $HBox/Controls/MarginContainer3/HBoxContainer/TimeLen
@onready var volslide = $Panel/MarginContainer/OptionsBox/HBoxContainer/Volume
@onready var disc = $HBox/Controls/Control/Control/Disc

##The file path to search for songs in.
var path : String
##The songs currently loaded by the player.
##Array of strings for names of files.
var songs : Array[String]
##The current song array index being played.
var id : int = 0
##The current MP3 stream playing at this time.
var mp3 : AudioStreamMP3
##The loop mode to do when current song ends.
##0-2; loop playlist, loop current, shuffle.
var loop : int = 0

var playlist : bool = false

func _process(delta: float) -> void:
	if audio.playing:
		var p = audio.get_playback_position()
		progress.value = p
		timecur.text = len_to_time(p)
		disc.rotation += delta * 2

func _ready() -> void:
	mp3 = AudioStreamMP3.new()
	var dir = DirAccess.open(SaveMgr.data.path)
	if dir.dir_exists(SaveMgr.data.path):
		setup(SaveMgr.data.path)
		volslide.value = SaveMgr.data.volume

func setup(p: String):
	playlist = false
	path = p
	search_for_files(path)
	make_buttons()
	SaveMgr.data.path = path
	SaveMgr.Save()

func search_for_files(p):
	songs.clear()
	for f in DirAccess.get_files_at(p):
		if f.ends_with('.mp3'):
			songs.append(f)

func make_buttons() -> void:
	for c in buttons.get_children():
		c.queue_free()
	var i = 0
	for s in songs:
		var spawn = load("res://Scenes/song_btn.tscn")
		var inst = spawn.instantiate()
		buttons.add_child(inst)
		if playlist:
			var o = s.reverse()
			var x = o.find("/")
			o = o.left(x).reverse()
			inst.setup(o.left(-4), i)
		else:
			inst.setup(s.left(-4), i)
		inst.connect("try_new_song", start_song)
		print(i)
		i += 1
	i = 0

func start_song(i):
	id = i
	audio.stop()
	var s = songs[id]
	var dat
	if playlist:
		dat = FileAccess.get_file_as_bytes(s)
	else:
		dat = FileAccess.get_file_as_bytes(path + "/" + s)
	mp3.data = dat
	audio.stream = mp3
	var l = audio.stream.get_length()
	progress.max_value = l
	timelen.text = len_to_time(l)
	audio.play()
	if playlist:
			var o = s.reverse()
			var x = o.find("/")
			o = o.left(x).reverse()
			title.text = o.left(-4)
	else:
		title.text = s.left(-4)
	ctrlplay.icon = load("res://Assets/Img/ctrlPause.png")
	nowplay.text = "NOW PLAYING"

func _on_volume_value_changed(value: float) -> void:
	audio.volume_linear = value

func _on_volume_drag_ended(value_changed: bool) -> void:
	if value_changed:
		SaveMgr.data.volume = volslide.value
		SaveMgr.Save()

func _on_ctrl_play_pressed() -> void:
	if audio.playing:
		audio.stream_paused = true
		ctrlplay.icon = load("res://Assets/Img/ctrlPlay.png")
		nowplay.text = "..."
	else:
		if not audio.stream:
			start_song(0)
			ctrlplay.icon = load("res://Assets/Img/ctrlPause.png")
			nowplay.text = "NOW PLAYING"
		else:
			audio.stream_paused = false
			ctrlplay.icon = load("res://Assets/Img/ctrlPause.png")
			nowplay.text = "NOW PLAYING"

func _on_ctrl_next_pressed() -> void:
	if (id + 1) > songs.size() - 1:
		start_song(0)
	else:
		start_song(id + 1)

func _on_ctrl_back_pressed() -> void:
	if audio.get_playback_position() >= 5.0:
		audio.play()
	else:
		if (id+1) <= 0:
			start_song(songs.size() - 1)
		else:
			start_song(id - 1)

func _on_play_progress_drag_started() -> void:
	audio.stream_paused = true

func _on_play_progress_drag_ended(_value_changed: bool) -> void:
	audio.play(progress.value)

func _on_play_progress_value_changed(value: float) -> void:
	timecur.text = len_to_time(value)

func _on_audio_stream_player_finished() -> void:
	match loop:
		0:
			if (id + 1) > songs.size():
				start_song(0)
			else:
				start_song(id + 1)
		1:
			audio.play()
		2:
			start_song(randi_range(0, songs.size() - 1))

func _on_set_path_pressed() -> void:
	var dialog = FileDialog.new()
	dialog.set_file_mode(FileDialog.FILE_MODE_OPEN_DIR)
	dialog.set_access(FileDialog.ACCESS_FILESYSTEM)
	dialog.set_use_native_dialog(true)
	dialog.connect("dir_selected", setup)
	dialog.current_path = path
	add_child(dialog)
	dialog.popup_centered_ratio()

func _on_ctrl_loop_pressed() -> void:
	if (loop + 1) > 2:
		loop = 0
	else:
		loop += 1
	match loop:
		0: ctrlloop.icon = load("res://Assets/Img/ctrlLoopList.png")
		1: ctrlloop.icon = load("res://Assets/Img/ctrlLoopOne.png")
		2: ctrlloop.icon = load("res://Assets/Img/ctrlShuffle.png")

func len_to_time(t: float):
	var minute = int(t/60)
	var sec = t - minute * 60
	var r = str(minute) + ":"
	if sec < 10:
		r += "0"
	r += str(floori(sec))
	return r

func _on_playlist_mgr_load_playlist(s: Array[String]) -> void:
	songs.clear()
	for p in s:
		songs.append(p)
	playlist = true
	make_buttons()
