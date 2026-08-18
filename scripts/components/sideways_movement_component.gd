# sideways_movement_component.gd
class_name SidewaysMovementComponent
extends MovementBase

signal jumped
signal double_jumped
signal extra_jumped(jump_number: int)
signal landed(motion: StringName)
signal wall_slid
signal fell_from_wall
signal dashed
signal dash_ended

@export_group("Movement")
@export var move_speed: float = 200.0
@export var run_speed: float = 400.0
@export var move_acceleration: float = 1200.0
@export var turn_acceleration: float = 3600.0
@export var move_friction: float = 1200.0

@export_group("Jump")
@export var jump_height: float = 64.0
@export var max_jumps: int = 2
@export var jump_gravity: float = 0.0
@export var coyote_time: float = 0.1
@export var jump_buffer_time: float = 0.1

@export_group("Fall")
@export var max_fall_speed: float = 600.0
@export var fall_gravity_offset: float = 0.0
@export var apex_hang_threshold: float = 40.0

@export_group("Wall")
@export var wall_slide_speed: float = 100.0
@export var wall_jump_enabled: bool = true

@export_group("Dash")
@export var dash_speed: float = 800.0
@export var dash_duration: float = 0.2
@export var dash_cooldown: float = 0.5
@export var crouch_collision_scale: float = 0.5
@export var crouch_shape_y_offset: float = 8.0

@export_range(0.0, 1.0, 0.05) var jump_cut_mult: float = 0.5
@export_range(0.0, 3.0, 0.05) var running_jump_height_mult: float = 1.5
@export_range(0.0, 3.0, 0.05) var speed_based_jump_distance_mult: float = 1.5
@export_range(0.0, 1.0, 0.05) var apex_hang_gravity_mult: float = 0.5

@export_group("Crouch")
@export_range(0.0, 1.0, 0.05) var crouch_speed_mult: float = 0.5

var facing_component: FacingComponent
var collision_shape: CollisionShape2D

var launch_component: LaunchComponent
var _was_moving: bool = false
var _coyote_timer: float = 0.0
var _jump_buffer_timer: float = 0.0
var _jumps_used: int = 0
var _current_motion: StringName = &"idle"
var _dash_timer: float = 0.0
var _dash_cooldown_timer: float = 0.0
var _standing_shape_position: Vector2
var _dash_direction: float = 1.0
var _is_running: bool = false

@onready var body: CharacterBody2D = get_parent() as CharacterBody2D
@onready var state_chart: StateChart = %StateChart
@onready var ground_state: StateChartState = %Ground
@onready var air_state: StateChartState = %Air
@onready var wall_slide_state: StateChartState = %WallSlide
@onready var dash_state: StateChartState = %Dash
@onready var crouch_state: StateChartState = %Crouch
@onready var base_gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta: float) -> void:
	_is_running = Input.is_action_pressed("run")
	if _dash_cooldown_timer > 0.0:
		_dash_cooldown_timer -= delta


func _on_ready() -> void:
	ground_state.state_physics_processing.connect(_on_ground_physics)
	air_state.state_physics_processing.connect(_on_air_physics)
	wall_slide_state.state_physics_processing.connect(_on_wall_slide_physics)
	wall_slide_state.state_entered.connect(_on_wall_slide_entered)
	dash_state.state_entered.connect(_on_dash_entered)
	dash_state.state_physics_processing.connect(_on_dash_physics)
	crouch_state.state_entered.connect(_on_crouch_entered)
	crouch_state.state_physics_processing.connect(_on_crouch_physics)
	crouch_state.state_exited.connect(_on_crouch_exited)
	if launch_component:
		track(launch_component.landed, _on_launch_landed)


func _on_setup() -> void:
	facing_component = get_component(FacingComponent) as FacingComponent
	collision_shape = get_component(CollisionShape2D, false) as CollisionShape2D
	launch_component = get_component(LaunchComponent, false) as LaunchComponent
	if collision_shape:
		_standing_shape_position = collision_shape.position


func _on_wall_slide_entered() -> void:
	_jump_buffer_timer = 0.0
	if wall_jump_enabled:
		_jumps_used = 0
		_coyote_timer = coyote_time


func _apply_horizontal(
	delta: float,
	input_dir: float,
	is_running: bool,
	speed_multiplier: float = 1.0,
) -> void:
	if input_dir == 0.0:
		body.velocity.x = move_toward(body.velocity.x, 0.0, move_friction * delta)
		if _was_moving and is_zero_approx(body.velocity.x):
			stopped.emit()
			_was_moving = false
	else:
		var turning: bool = (
			not is_zero_approx(body.velocity.x) and signf(body.velocity.x) != signf(input_dir)
		)
		var accel_rate: float = turn_acceleration if turning else move_acceleration
		var target_speed: float = (run_speed if is_running else move_speed) * speed_multiplier
		body.velocity.x = move_toward(body.velocity.x, input_dir * target_speed, accel_rate * delta)

		var changed: bool = facing_component.update(Vector2(input_dir, 0.0))
		if not _was_moving or changed:
			moved.emit(facing_component.facing)
		_was_moving = true


func _update_current_motion(on_ground: bool, input_dir: float, is_running: bool) -> void:
	var motion: StringName
	if input_dir != 0.0 and body.is_on_wall():
		motion = &"push"
	elif is_running:
		motion = &"run"
	elif input_dir != 0.0:
		motion = &"walk"
	else:
		motion = &"idle"

	if motion == _current_motion:
		return
	_current_motion = motion
	if on_ground:
		ground_motion_changed.emit(motion)


func _try_jump(is_running: bool) -> bool:
	var can_jump: bool = _coyote_timer > 0.0 or _jumps_used < max_jumps
	if _jump_buffer_timer <= 0.0 or not can_jump:
		return false

	var height: float = jump_height * (running_jump_height_mult if is_running else 1.0)
	var rise_gravity: float = jump_gravity if jump_gravity > 0.0 else base_gravity
	body.velocity.y = -sqrt(2.0 * rise_gravity * height)

	var speed_ratio: float = clampf(absf(body.velocity.x) / run_speed, 0.0, 1.0)
	body.velocity.x *= lerpf(1.0, speed_based_jump_distance_mult, speed_ratio)

	_coyote_timer = 0.0
	_jump_buffer_timer = 0.0
	_jumps_used += 1

	if _jumps_used == 1:
		jumped.emit()
	elif _jumps_used == 2:
		double_jumped.emit()
	else:
		extra_jumped.emit(_jumps_used)
	return true


func _try_dash() -> bool:
	if _dash_cooldown_timer > 0.0:
		return false
	return Input.is_action_just_pressed("dash")


func _update_jump_buffer(delta: float) -> void:
	if Input.is_action_just_pressed("jump"):
		_jump_buffer_timer = jump_buffer_time
	else:
		_jump_buffer_timer -= delta


func _on_ground_physics(delta: float) -> void:
	var input_dir: float = Input.get_axis("move_left", "move_right")

	_coyote_timer = coyote_time
	_update_jump_buffer(delta)

	if _try_dash():
		state_chart.send_event(&"dash")
		return

	if Input.is_action_pressed("crouch"):
		state_chart.send_event(&"crouch")
		return

	_apply_horizontal(delta, input_dir, _is_running)

	if _try_jump(_is_running):
		state_chart.send_event(&"jump")
		return

	body.move_and_slide()
	_update_current_motion(true, input_dir, _is_running)
	if not body.is_on_floor():
		state_chart.send_event(&"fall")


func _on_air_physics(delta: float) -> void:
	if _try_dash():
		state_chart.send_event(&"dash")
		return

	var gravity: float = (
		jump_gravity
		if (jump_gravity > 0.0 and body.velocity.y < 0.0)
		else base_gravity + fall_gravity_offset
	)
	if absf(body.velocity.y) < apex_hang_threshold:
		gravity *= apex_hang_gravity_mult
	body.velocity.y = minf(body.velocity.y + gravity * delta, max_fall_speed)

	if body.is_on_ceiling() and body.velocity.y < 0.0:
		body.velocity.y = 0.0

	_coyote_timer -= delta
	_update_jump_buffer(delta)

	if Input.is_action_just_released("jump") and body.velocity.y < 0.0:
		body.velocity.y *= jump_cut_mult

	var input_dir: float = Input.get_axis("move_left", "move_right")
	_apply_horizontal(delta, input_dir, false)
	_try_jump(false)

	var was_grounded: bool = body.is_on_floor()
	body.move_and_slide()
	_update_current_motion(false, input_dir, false)

	if not was_grounded and body.is_on_floor():
		landed.emit(_current_motion)
		_jumps_used = 0
		state_chart.send_event(&"land")
		ground_motion_changed.emit(_current_motion)
		return

	if body.is_on_wall_only() and input_dir != 0.0:
		state_chart.send_event(&"wall_slide")


func _on_wall_slide_physics(delta: float) -> void:
	body.velocity.y = minf(
		body.velocity.y + (base_gravity + fall_gravity_offset) * delta,
		wall_slide_speed,
	)
	wall_slid.emit()
	_update_jump_buffer(delta)

	if wall_jump_enabled and _try_jump(false):
		state_chart.send_event(&"jump")
		return

	var input_dir: float = Input.get_axis("move_left", "move_right")
	_apply_horizontal(delta, input_dir, false)

	var was_grounded: bool = body.is_on_floor()
	body.move_and_slide()

	if not was_grounded and body.is_on_floor():
		landed.emit(_current_motion)
		state_chart.send_event(&"land")
		ground_motion_changed.emit(_current_motion)
		return

	if not body.is_on_wall():
		state_chart.send_event(&"fall")
		fell_from_wall.emit()


func _on_dash_entered() -> void:
	_dash_timer = dash_duration
	_dash_cooldown_timer = dash_cooldown
	_dash_direction = facing_component.facing.x if not is_zero_approx(facing_component.facing.x) else 1.0
	dashed.emit()


func _on_dash_physics(delta: float) -> void:
	body.velocity = Vector2(_dash_direction * dash_speed, 0.0)
	_dash_timer -= delta
	body.move_and_slide()

	if _dash_timer > 0.0:
		return

	if body.is_on_floor():
		_update_current_motion(true, Input.get_axis("move_left", "move_right"), _is_running)
		landed.emit(_current_motion)
		state_chart.send_event(&"land")
		ground_motion_changed.emit(_current_motion)
	else:
		dash_ended.emit()
		state_chart.send_event(&"fall")


func _on_crouch_entered() -> void:
	if not collision_shape:
		return
	collision_shape.scale.y = crouch_collision_scale
	collision_shape.position.y = _standing_shape_position.y + crouch_shape_y_offset


func _on_crouch_physics(delta: float) -> void:
	var input_dir: float = Input.get_axis("move_left", "move_right")
	_apply_horizontal(delta, input_dir, false, crouch_speed_mult)
	body.move_and_slide()

	var motion: StringName = &"crouch_walk" if input_dir != 0.0 else &"crouch_idle"
	if motion != _current_motion:
		_current_motion = motion
		ground_motion_changed.emit(motion)

	if not body.is_on_floor():
		state_chart.send_event(&"fall")
		return
	if not Input.is_action_pressed("crouch"):
		state_chart.send_event(&"crouch_end")


func _on_crouch_exited() -> void:
	if not collision_shape:
		return
	collision_shape.scale.y = 1.0
	collision_shape.position.y = _standing_shape_position.y


func _on_launch_landed() -> void:
	_jumps_used = 0
	_coyote_timer = coyote_time
	_update_current_motion(true, Input.get_axis("move_left", "move_right"), _is_running)
	landed.emit(_current_motion)
	state_chart.send_event(&"land")
	ground_motion_changed.emit(_current_motion)
