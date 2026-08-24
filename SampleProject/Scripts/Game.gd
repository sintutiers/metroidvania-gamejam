<<<<<<< HEAD
# This is the main script of the game. It manages the current map and some other stuff.
extends "res://addons/MetroidvaniaSystem/Template/Scripts/MetSysGame.gd"
class_name Game

const SaveManager = preload("res://addons/MetroidvaniaSystem/Template/Scripts/SaveManager.gd")
const SAVE_PATH = "user://example_save_data.sav"

# The game starts in this map. Uses special annotation that enabled dedicated inspector plugin.
@export_file("room_link") var starting_map: String

# Number of collected collectibles. Setting it also updates the counter.
=======
class_name Game
extends "res://addons/MetroidvaniaSystem/Template/Scripts/MetSysGame.gd"

const SaveManager = preload("res://addons/MetroidvaniaSystem/Template/Scripts/SaveManager.gd")

var ability_component: AbilityComponent
var respawn_component: RespawnComponent
var health: Health
@export_file("room_link") var starting_map: String
>>>>>>> origin/main
var collectibles: int:
	set(count):
		collectibles = count
		%CollectibleCount.text = "%d/7" % count
<<<<<<< HEAD

# The coordinates of generated rooms. MetSys does not keep this list, so it needs to be done manually.
var generated_rooms: Array[Vector3i]
# The typical array of game events. It's supplementary to the storable objects.
var events: Array[String]
# For Custom Runner integration.
var custom_run: bool
# See LoopScript.
var loop: String

func _ready() -> void:
	# A trick for static object reference (before static vars were a thing).
	get_script().set_meta(&"singleton", self)
	# Make sure MetSys is in initial state.
	# Does not matter in this project, but normally this ensures that the game works correctly when you exit to menu and start again.
	MetSys.reset_state()
	# Assign player for MetSysGame.
	set_player($Player)
	
	if FileAccess.file_exists(SAVE_PATH):
		# If save data exists, load it using MetSys SaveManager.
		var save_manager := SaveManager.new()
		save_manager.load_from_text(SAVE_PATH)
		# Assign loaded values.
		collectibles = save_manager.get_value("collectible_count")
		generated_rooms.assign(save_manager.get_value("generated_rooms"))
		events.assign(save_manager.get_value("events"))
		player.abilities.assign(save_manager.get_value("abilities"))
		
		if not custom_run:
			var loaded_starting_map: String = save_manager.get_value("current_room")
			if not loaded_starting_map.is_empty(): # Some compatibility problem.
				starting_map = loaded_starting_map
	else:
		# If no data exists, set empty one.
		MetSys.set_save_data()
	
	# Initialize room when it changes.
	room_loaded.connect(init_room, CONNECT_DEFERRED)
	# Load the starting room.
	load_room(starting_map)
	
	# Find the save point and teleport the player to it, to start at the save point.
	var start := map.get_node_or_null(^"SavePoint")
	if start and not custom_run:
		player.position = start.position
	
	# Add module for room transitions.
	add_module("RoomTransitions.gd")
	# You can enable alternate transition effect by using this module instead.
	#add_module("ScrollingRoomTransitions.gd")
	
	# Reset position tracking (feature specific to this project).
	await get_tree().physics_frame
	reset_map_starting_coords.call_deferred()
	
	# Make sure minimap is at correct position (required for themes to work correctly).
	%Minimap.set_offsets_preset(Control.PRESET_TOP_RIGHT, Control.PRESET_MODE_MINSIZE, 8)

# Debugging helper. Press F2 to quickly reload game.
func _input(event: InputEvent) -> void:
	var k := event as InputEventKey
	if k and k.pressed and k.keycode == KEY_F2:
		var cr: Script
		# CustomRunner can't be used directly, since the addon is optional.
		if ResourceLoader.exists("res://addons/CustomRunner/CustomRunner.gd"):
			cr = load("res://addons/CustomRunner/CustomRunner.gd")
		
		if cr and cr.is_custom_running():
			get_tree().change_scene_to_file.call_deferred("res://SampleProject/CustomRunnerIntegration/CustomStart.tscn")
		else:
			get_tree().reload_current_scene()

# Returns this node from anywhere.
static func get_singleton() -> Game:
	return (Game as Script).get_meta(&"singleton") as Game

# Save game using MetSys SaveManager.
func save_game():
	var save_manager := SaveManager.new()
	save_manager.set_value("collectible_count", collectibles)
	save_manager.set_value("generated_rooms", generated_rooms)
	save_manager.set_value("events", events)
	save_manager.set_value("current_room", MetSys.get_current_room_id())
	save_manager.set_value("abilities", player.abilities)
	save_manager.save_as_text(SAVE_PATH)

func reset_map_starting_coords():
	$UI/MapWindow.reset_starting_coords()

func init_room():
	MetSys.get_current_room_instance().adjust_camera_limits($Player/Camera2D)
	player.on_enter()
	
	# Initializes MetSys.get_current_coords(), so you can use it from the beginning.
	if MetSys.last_player_position.x == Vector2i.MAX.x:
		MetSys.set_player_position(player.position)

# Customized load function that handles maps generated in Dice.tscn and loops in LoopRoom.tscn.
func _load_room(path: String) -> Node:
	if not path.begins_with("GEN"):
		# See LoopScript.
		if not loop.is_empty():
			path = loop
			loop = ""
		return super(path)
	
	# Base scene that will be customized (Junction.tscn).
	var prototype := preload("uid://bikgu4uxf7vxt").instantiate()
	prototype.scene_file_path = path
	
	var config := path.split("/")
	# Assign values to the scene (see the script in Junction.tscn).
	prototype.exits = config[2].to_int()
	prototype.has_collectible = config[3] == "true"
	# Apply the values. It has to happen before the scene enters tree.
	prototype.apply_config()
	
	return prototype
=======
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
>>>>>>> origin/main
