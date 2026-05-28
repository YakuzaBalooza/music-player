extends Node
const path = "user://save.tres"
var data: SaveData = null

# Attempt to load SaveGame via Load().
func _ready() -> void:
	Load()

# Save game data, creating a new SaveGame if one doesn't exist.
func Save() -> void:
	if not ResourceLoader.exists(path):
		data = SaveData.new()
	ResourceSaver.save(data, path)

# Load game save, calling Save() if one doesn't exist.
func Load() -> void:
	if ResourceLoader.exists(path):
		data = ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE)
	else:
		data = SaveData.new()
		Save()

# Delete save data and create new data with Save().
func Reset() -> void:
	if ResourceLoader.exists(path):
		DirAccess.remove_absolute(path)
	Save()
