# top_down_movement_component.gd
class_name TopDownMovementComponent
extends MovementBase

@export var move_speed: float = 100.0
@export var locks_during_interact: bool = true

var _was_moving: bool = false
var _locked: bool = false

var input_component: InputComponent
var facing_component: FacingComponent

@onready var body: CharacterBody2D = get_parent() as CharacterBody2D
@onready var move_state: StateChartState = %Move


func _ready() -> void:
	super._ready()
	track(move_state.state_physics_processing, _on_move_physics)

	if locks_during_interact:
		var interact_component := get_component(InteractComponent, false) as InteractComponent
		if interact_component:
			track(
				interact_component.interact_started,
				func() -> void:
					_locked = true,
			)
			track(
				interact_component.interact_ended,
				func() -> void:
					_locked = false,
			)


func _on_setup() -> void:
	facing_component = get_component(FacingComponent) as FacingComponent
	input_component = get_component(InputComponent) as InputComponent


func _on_move_physics(_delta: float) -> void:
	var input_dir: Vector2 = input_component.get_movement_vector()

	if _locked or input_dir.is_zero_approx():
		body.velocity = Vector2.ZERO
		if _was_moving:
			stopped.emit()
		_was_moving = false
	else:
		body.velocity = input_dir * move_speed
		var changed: bool = facing_component.update(input_dir)
		if not _was_moving or changed:
			moved.emit(facing_component.facing)
		_was_moving = true

	body.move_and_slide(
