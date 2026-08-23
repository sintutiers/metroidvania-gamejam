class_name Game
extends "res://addons/MetroidvaniaSystem/Template/Scripts/MetSysGame.gd"

const SaveManager = preload("res://addons/MetroidvaniaSystem/Template/Scripts/SaveManager.gd")

var ability_component: AbilityComponent
var respawn_component: RespawnComponent
var health: Health
@export_file("room_link") var starting_map: String
var collectibles: int:
	set(count):
		collectibles = count
		%CollectibleCount.text = "%d/7" % count
var generated_rooms: Array[Vector3i]
var events: Array[String]
var custom_run: bool
var loop: String


static func get_singleton() -> Game:
	return (Game as Script).get_meta(&"singleton") as Game


func _ready() -> void:
	get_script().set_meta(&"singleton", self)
	print(ResourceUID.get_id_path(ResourceUID.text_to_id("uid://cv55nv1c2sbiq")))
	MetSys.reset_state()
	set_player($Player)
	ability_component = Component.find_component(player, AbilityComponent) as AbilityComponent
	respawn_component = Component.find_component(player, RespawnComponent, false) as RespawnComponent
	health = Component.find_component(player, Health, false) as Health
	MetSys.set_save_data()
	if GameState.has_game_state():
		var game_state := GameState.get_or_create_state()
		collectibles = game_state.collectibles
		generated_rooms.assign(game_state.generated_rooms)
		events.assign(game_state.events)
		for id: String in game_state.ability_levels:
			ability_component.set_level(StringName(id), game_state.ability_levels[id])
		if not custom_run and not game_state.checkpoint_level_path.is_empty():
			if ResourceUID.has_id(ResourceUID.text_to_id(game_state.checkpoint_level_path)):
				starting_map = game_state.checkpoint_level_path
			else:
				push_warning(
					"Stale checkpoint UID, falling back to starting_map: %s"
					% game_state.checkpoint_level_path
				)
	room_loaded.connect(init_room, CONNECT_DEFERRED)
	load_room(starting_map)
	var start := map.get_node_or_null(^"SavePoint")
	if start and not custom_run:
		player.position = start.position
	add_module("RoomTransitions.gd")
	await get_tree().physics_frame
	reset_map_starting_coords.call_deferred()
	%Minimap.set_offsets_preset(Control.PRESET_TOP_RIGHT, Control.PRESET_MODE_MINSIZE, 8)


func _input(event: InputEvent) -> void:
	var k := event as InputEventKey
	if k and k.pressed and k.keycode == KEY_F2:
		get_tree().reload_current_scene()


func save_game() -> void:
	var game_state := GameState.get_or_create_state()
	game_state.collectibles = collectibles
	game_state.generated_rooms = generated_rooms
	game_state.events = events
	game_state.current_level_path = MetSys.get_current_room_id()
	var levels_out: Dictionary = { }
	for id: StringName in ability_component.get_all_levels():
		levels_out[String(id)] = ability_component.get_level(id)
	game_state.ability_levels = levels_out
	GlobalState.save()


func reset_map_starting_coords() -> void:
	$UI/MapWindow.reset_starting_coords()


func init_room() -> void:
	if respawn_component:
		respawn_component.mark_room_entry_point()
	if MetSys.last_player_position.x == Vector2i.MAX.x:
		MetSys.set_player_position(player.position)
	var room_instance: MetroidvaniaSystem.RoomInstance = MetSys.get_current_room_instance()
	var room_camera := room_instance.get_node_or_null(^"PhantomCamera2D") as PhantomCamera2D
	if room_camera:
		room_camera.follow_target = player
