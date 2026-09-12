extends LevelManager

@export_dir var room_scenes_root: String = "res://scenes/game/levels/"

var _portal_locations: Dictionary[StringName, String] = { }
var _portals_prescanned: bool = false


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


func register_portal(portal_id: StringName, scene_path: String) -> void:
	_portal_locations[portal_id] = scene_path
	print("Portal registered: ", portal_id, " -> ", scene_path)


func get_scene_for_portal(portal_id: StringName) -> String:
	if not _portal_locations.has(portal_id) and not _portals_prescanned:
		_prescan_all_rooms()
	return _portal_locations.get(portal_id, "")


func _prescan_all_rooms() -> void:
	_portals_prescanned = true
	var current_scene_path: String = Game.get_singleton().map.scene_file_path if Game \
			.get_singleton() \
			.map else ""
	for scene_path in _find_scenes_recursive(room_scenes_root):
		if scene_path == current_scene_path:
			continue
		_scan_room_scene(scene_path)


func _find_scenes_recursive(dir_path: String) -> Array[String]:
	var result: Array[String] = []
	var dir := DirAccess.open(dir_path)
	if not dir:
		return result
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		var full_path: String = dir_path.path_join(file_name)
		if dir.current_is_dir() and not file_name.begins_with("."):
			result.append_array(_find_scenes_recursive(full_path))
		elif file_name.ends_with(".tscn"):
			result.append(full_path)
		file_name = dir.get_next()
	dir.list_dir_end()
	return result


func _scan_room_scene(scene_path: String) -> void:
	if not ResourceLoader.exists(scene_path):
		return
	var packed: PackedScene = load(scene_path)
	if not packed:
		return
	var instance: Node = packed.instantiate()
	instance.set_meta(&"fake_map", true)
	_register_portals_in_subtree(instance, scene_path)
	instance.free()


func _register_portals_in_subtree(node: Node, scene_path: String) -> void:
	for child: Node in node.get_children():
		if child is Portal:
			register_portal(child.portal_id, scene_path)
		_register_portals_in_subtree(child, scene_path)
