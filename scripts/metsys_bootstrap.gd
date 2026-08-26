extends Node


func _ready() -> void:
	if not MetSys.save_data:
		MetSys.reset_state()
		MetSys.set_save_data()
