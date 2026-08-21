# animation_component.gd
class_name AnimationComponent
extends Component

var _is_airborne: bool = false
var _is_landing: bool = false
var _pending_ground_motion: StringName = &"idle"
var _current_motion: StringName = &"idle"
var _is_aiming: bool = false

@onready var sprite: AnimatedSprite2D = %AnimatedSprite2D


func _on_ready() -> void:
	sprite.animation_finished.connect(_on_animation_finished)


func _on_setup() -> void:
	var movement := get_component(MovementBase, false) as MovementBase
	if movement:
		track(movement.ground_motion_changed, _on_ground_motion_changed)
		track(movement.jumped, _on_jumped)
		track(movement.wall_jumped, _on_wall_jumped)
		track(movement.extra_jumped, _on_extra_jumped)
		track(movement.landed, _on_landed)
		track(movement.wall_slid, _on_wall_slid)
		track(movement.fell_from_wall, _on_airspin)
		track(movement.dashed, _on_dashed)
		track(movement.dash_ended, _on_dash_ended)
	var launch := get_component(LaunchComponent, false) as LaunchComponent
	if launch:
		track(launch.fell, _on_launched)
	var attack := get_component(AttackComponent, false) as AttackComponent
	if attack:
		track(attack.fired, _on_fired)
		track(attack.aim_started, _on_aim_started)
		track(attack.aim_ended, _on_aim_ended)
	var facing := get_component(FacingComponent, false) as FacingComponent
	if facing:
		track(facing.flipped, _on_flipped)


func _on_ground_motion_changed(motion: StringName) -> void:
	_current_motion = motion
	if _is_aiming:
		return
	if _is_landing:
		if motion == &"walk" or motion == &"run":
			_is_landing = false
			sprite.play(motion)
			return
		_pending_ground_motion = motion
		return
	if _is_airborne:
		return
	sprite.play(motion)


func _on_jumped(jump_number: int) -> void:
	_is_airborne = true
	sprite.play(&"jump" if jump_number == 1 else &"airspin")


func _on_wall_jumped() -> void:
	_is_airborne = true
	sprite.play(&"jump")


func _on_airspin() -> void:
	_is_airborne = true
	sprite.play(&"airspin")


func _on_extra_jumped(_jump_number: int) -> void:
	_is_airborne = true
	sprite.play(&"airspin")


func _on_wall_slid() -> void:
	_is_airborne = true
	if sprite.animation != &"wall_slide":
		sprite.play(&"wall_slide")


func _on_dashed() -> void:
	_is_airborne = true
	sprite.play(&"dash")


func _on_dash_ended() -> void:
	sprite.play(&"fall")


func _on_launched() -> void:
	_is_airborne = true
	sprite.play(&"airspin")


func _on_landed(motion: StringName) -> void:
	_is_airborne = false
	_is_landing = true
	_pending_ground_motion = motion
	sprite.play(&"fall")


func _on_fired() -> void:
	if _is_airborne:
		return
	var is_moving: bool = _current_motion == &"walk" or _current_motion == &"run"
	sprite.play(&"shoot_running" if is_moving else &"shoot")


func _on_aim_started() -> void:
	_is_aiming = true
	if _is_airborne:
		return
	sprite.play(&"aim")


func _on_aim_ended() -> void:
	_is_aiming = false
	if _is_airborne:
		return
	sprite.play(_current_motion)


func _on_animation_finished() -> void:
	if sprite.animation != &"fall":
		return
	_is_landing = false
	sprite.play(_pending_ground_motion)


func _on_flipped(new_facing_x: float) -> void:
	sprite.flip_h = new_facing_x < 0.0
