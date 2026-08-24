# animation_component.gd
class_name AnimationComponent
extends Component

<<<<<<< HEAD
var _is_airborne: bool = false
var _is_landing: bool = false
var _pending_ground_motion: StringName = &"idle"
var _current_motion: StringName = &"idle"
var _is_aiming: bool = false
=======
@export_group("Flip")
@export var flip_duration: float = 0.1

var _is_airborne: bool = false
var _is_landing: bool = false
var _is_tumbling: bool = false
var _pending_ground_motion: StringName = Motions.IDLE
var _current_motion: StringName = Motions.IDLE
var _is_aiming: bool = false
var _flip_tween: Tween
>>>>>>> origin/main

@onready var sprite: AnimatedSprite2D = %AnimatedSprite2D


func _on_ready() -> void:
<<<<<<< HEAD
	sprite.animation_finished.connect(_on_animation_finished)


func _on_setup() -> void:
	var movement := get_component(MovementBase, false) as MovementBase
	if movement:
		track(movement.ground_motion_changed, _on_ground_motion_changed)

	var sideways := movement as SidewaysMovementComponent
	if sideways:
		track(sideways.jumped, _on_jumped)
		track(sideways.wall_jumped, _on_wall_jumped)
		track(sideways.extra_jumped, _on_extra_jumped)
		track(sideways.landed, _on_landed)
		track(sideways.wall_slid, _on_wall_slid)
		track(sideways.fell_from_wall, _on_airspin)
		track(sideways.dashed, _on_dashed)
		track(sideways.dash_ended, _on_dash_ended)

	var launch := get_component(LaunchComponent, false) as LaunchComponent
	if launch:
		track(launch.fell, _on_launched)

=======
	track(sprite.animation_finished, _on_animation_finished)


func _on_setup() -> void:
	var movement := get_component(PlatformerMovementBase, false) as PlatformerMovementBase
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
		track(movement.started_falling, _on_started_falling)
	var launch := get_component(LaunchComponent, false) as LaunchComponent
	if launch:
		track(launch.fell, _on_launched)
>>>>>>> origin/main
	var attack := get_component(AttackComponent, false) as AttackComponent
	if attack:
		track(attack.fired, _on_fired)
		track(attack.aim_started, _on_aim_started)
		track(attack.aim_ended, _on_aim_ended)
<<<<<<< HEAD

=======
>>>>>>> origin/main
	var facing := get_component(FacingComponent, false) as FacingComponent
	if facing:
		track(facing.flipped, _on_flipped)


func _on_ground_motion_changed(motion: StringName) -> void:
	_current_motion = motion
	if _is_aiming:
		return
	if _is_landing:
<<<<<<< HEAD
		if motion == &"walk" or motion == &"run":
=======
		if motion == Motions.WALK or motion == Motions.RUN:
>>>>>>> origin/main
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
<<<<<<< HEAD
	sprite.play(&"jump" if jump_number == 1 else &"airspin")
=======
	_is_tumbling = jump_number != 1
	sprite.play(Animations.JUMP if jump_number == 1 else Animations.AIRSPIN)
>>>>>>> origin/main


func _on_wall_jumped() -> void:
	_is_airborne = true
<<<<<<< HEAD
	sprite.play(&"jump")
=======
	_is_tumbling = false
	sprite.play(Animations.JUMP)
>>>>>>> origin/main


func _on_airspin() -> void:
	_is_airborne = true
<<<<<<< HEAD
	sprite.play(&"airspin")
=======
	_is_tumbling = true
	sprite.play(Animations.AIRSPIN)
>>>>>>> origin/main


func _on_extra_jumped(_jump_number: int) -> void:
	_is_airborne = true
<<<<<<< HEAD
	sprite.play(&"airspin")
=======
	_is_tumbling = true
	sprite.play(Animations.AIRSPIN)
>>>>>>> origin/main


func _on_wall_slid() -> void:
	_is_airborne = true
<<<<<<< HEAD
	if sprite.animation != &"wall_slide":
		sprite.play(&"wall_slide")
=======
	_is_tumbling = false
	if sprite.animation != Animations.WALL_SLIDE:
		sprite.play(Animations.WALL_SLIDE)
>>>>>>> origin/main


func _on_dashed() -> void:
	_is_airborne = true
<<<<<<< HEAD
	sprite.play(&"dash")


func _on_dash_ended() -> void:
	sprite.play(&"fall")
=======
	_is_tumbling = false
	sprite.play(Animations.DASH)


func _on_dash_ended() -> void:
	sprite.play(Animations.FALL)
>>>>>>> origin/main


func _on_launched() -> void:
	_is_airborne = true
<<<<<<< HEAD
	sprite.play(&"airspin")
=======
	sprite.play(Animations.AIRSPIN)
>>>>>>> origin/main


func _on_landed(motion: StringName) -> void:
	_is_airborne = false
	_is_landing = true
<<<<<<< HEAD
	_pending_ground_motion = motion
	sprite.play(&"fall")
=======
	_is_tumbling = false
	_pending_ground_motion = motion
	sprite.play(Animations.FALL)
>>>>>>> origin/main


func _on_fired() -> void:
	if _is_airborne:
		return
<<<<<<< HEAD
	var is_moving: bool = _current_motion == &"walk" or _current_motion == &"run"
	sprite.play(&"shoot_running" if is_moving else &"shoot")
=======
	var is_moving: bool = _current_motion == Motions.WALK or _current_motion == Motions.RUN
	sprite.play(Animations.SHOOT_RUNNING if is_moving else Animations.SHOOT)
>>>>>>> origin/main


func _on_aim_started() -> void:
	_is_aiming = true
	if _is_airborne:
		return
<<<<<<< HEAD
	sprite.play(&"aim")
=======
	sprite.play(Animations.AIM)
>>>>>>> origin/main


func _on_aim_ended() -> void:
	_is_aiming = false
	if _is_airborne:
		return
	sprite.play(_current_motion)


<<<<<<< HEAD
func _on_animation_finished() -> void:
	if sprite.animation != &"fall":
=======
func _on_started_falling() -> void:
	if _is_aiming or _is_tumbling:
		return
	_is_airborne = true
	sprite.play(Animations.FALLING)


func _on_animation_finished() -> void:
	if sprite.animation != Animations.FALL:
>>>>>>> origin/main
		return
	_is_landing = false
	sprite.play(_pending_ground_motion)


func _on_flipped(new_facing_x: float) -> void:
<<<<<<< HEAD
	sprite.flip_h = new_facing_x < 0.0
=======
	var target_scale_x: float = -1.0 if new_facing_x < 0.0 else 1.0
	if _flip_tween and _flip_tween.is_running():
		_flip_tween.kill()
	_flip_tween = create_tween()
	_flip_tween.tween_property(sprite, "scale:x", target_scale_x, flip_duration)
>>>>>>> origin/main
