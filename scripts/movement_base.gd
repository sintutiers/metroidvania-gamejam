class_name MovementBase
extends Component

signal moved(direction: Vector2)
signal stopped
signal ground_motion_changed(motion: StringName)
signal jumped(jump_number: int)
signal wall_jumped
signal extra_jumped(jump_number: int)
signal landed(motion: StringName)
signal wall_slid
signal fell_from_wall
signal dashed
signal dash_ended
