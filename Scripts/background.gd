extends TextureRect

#func _ready() -> void:
	#var dir = DirAccess.open(SaveMgr.data.bg)
	#if dir.dir_exists(SaveMgr.data.bg):
		#set_bg(SaveMgr.data.bg)

func _on_set_bg_pressed() -> void:
	var dialog = FileDialog.new()
	dialog.set_file_mode(FileDialog.FILE_MODE_OPEN_FILE)
	dialog.set_access(FileDialog.ACCESS_FILESYSTEM)
	dialog.set_use_native_dialog(true)
	dialog.connect("file_selected", set_bg)
	add_child(dialog)
	dialog.popup_centered_ratio()

func set_bg(p: String):
	var img = Image.new()
	img.load(p)
	var tt = ImageTexture.create_from_image(img)
	texture = tt
	SaveMgr.data.bg = p
	SaveMgr.Save()
