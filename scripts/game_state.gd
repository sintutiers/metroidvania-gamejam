<<<<<<< HEAD
class_name GameState
extends Resource

const STATE_NAME : String = "GameState"
const FILE_PATH = "res://scripts/game_state.gd"

@export var level_states : Dictionary = {}
@export var current_level_path : String
@export var checkpoint_level_path : String
@export var total_games_played : int
@export var play_time : int
@export var total_time : int

static func get_level_state(level_state_key : String) -> LevelState:
	if not has_game_state(): 
		return
	var game_state := get_or_create_state()
	if level_state_key.is_empty() : return
	if level_state_key in game_state.level_states:
		return game_state.level_states[level_state_key] 
=======
# scripts/game_state.gd
class_name GameState
extends Resource

const STATE_NAME: String = "GameState"
const FILE_PATH = "res://scripts/game_state.gd"

@export var level_states: Dictionary = { }
@export var current_level_path: String
@export var checkpoint_level_path: String
@export var total_games_played: int
@export var play_time: int
@export var total_time: int

# temporary home for MetSys-related save data, until/unless we adopt MetSys's own SaveManager
@export var collectibles: int
@export var generated_rooms: Array[Vector3i] = []
@export var events: Array[String] = []
@export var ability_levels: Dictionary = { }


static func get_level_state(level_state_key: String) -> LevelState:
	if not has_game_state():
		return
	var game_state := get_or_create_state()
	if level_state_key.is_empty():
		return
	if level_state_key in game_state.level_states:
		return game_state.level_states[level_state_key]
>>>>>>> origin/main
	else:
		var new_level_state := LevelState.new()
		game_state.level_states[level_state_key] = new_level_state
		GlobalState.save()
		return new_level_state

<<<<<<< HEAD
static func has_game_state() -> bool:
	return GlobalState.has_state(STATE_NAME)

static func get_or_create_state() -> GameState:
	return GlobalState.get_or_create_state(STATE_NAME, FILE_PATH)

static func get_current_level_path() -> String:
	if not has_game_state(): 
=======

static func has_game_state() -> bool:
	return GlobalState.has_state(STATE_NAME)


static func get_or_create_state() -> GameState:
	return GlobalState.get_or_create_state(STATE_NAME, FILE_PATH)


static func get_current_level_path() -> String:
	if not has_game_state():
>>>>>>> origin/main
		return ""
	var game_state := get_or_create_state()
	return game_state.current_level_path

<<<<<<< HEAD
static func get_checkpoint_level_path() -> String:
	if not has_game_state(): 
=======

static func get_checkpoint_level_path() -> String:
	if not has_game_state():
>>>>>>> origin/main
		return ""
	var game_state := get_or_create_state()
	return game_state.checkpoint_level_path

<<<<<<< HEAD
static func get_levels_reached() -> int:
	if not has_game_state(): 
=======

static func get_levels_reached() -> int:
	if not has_game_state():
>>>>>>> origin/main
		return 0
	var game_state := get_or_create_state()
	return game_state.level_states.size()

<<<<<<< HEAD
static func set_checkpoint_level_path(level_path : String) -> void:
=======

static func set_checkpoint_level_path(level_path: String) -> void:
>>>>>>> origin/main
	var game_state := get_or_create_state()
	game_state.checkpoint_level_path = level_path
	get_level_state(level_path)
	GlobalState.save()

<<<<<<< HEAD
static func set_current_level_path(level_path : String) -> void:
=======

static func set_current_level_path(level_path: String) -> void:
>>>>>>> origin/main
	var game_state := get_or_create_state()
	game_state.current_level_path = level_path
	GlobalState.save()

<<<<<<< HEAD
=======

>>>>>>> origin/main
static func start_game() -> void:
	var game_state := get_or_create_state()
	game_state.total_games_played += 1
	GlobalState.save()
<<<<<<< HEAD
=======
	if not MetSys.save_data:
		MetSys.reset_state()
		MetSys.set_save_data()

>>>>>>> origin/main

static func continue_game() -> void:
	var game_state := get_or_create_state()
	game_state.current_level_path = game_state.checkpoint_level_path
	GlobalState.save()

<<<<<<< HEAD
static func reset() -> void:
	var game_state := get_or_create_state()
	game_state.level_states = {}
=======

static func reset() -> void:
	var game_state := get_or_create_state()
	game_state.level_states = { }
>>>>>>> origin/main
	game_state.current_level_path = ""
	game_state.checkpoint_level_path = ""
	game_state.play_time = 0
	game_state.total_time = 0
<<<<<<< HEAD
=======
	game_state.collectibles = 0
	game_state.generated_rooms = []
	game_state.events = []
	game_state.ability_levels = { }
>>>>>>> origin/main
	GlobalState.save()
