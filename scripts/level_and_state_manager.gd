extends LevelManager


func _ready() -> void:
	pass


func set_current_level_path(value: String) -> void:
	super.set_current_level_path(value)
	GameState.set_current_level_path(value)


func set_checkpoint_level_path(value: String) -> void:
	super.set_checkpoint_level_path(value)
	GameState.set_checkpoint_level_path(value)


func get_checkpoint_level_path() -> String:
	return GameState.get_checkpoint_level_path()
