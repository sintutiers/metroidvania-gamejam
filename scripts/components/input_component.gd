class_name InputComponent
extends Component


func move_axis() -> float:
	return 0.0


func run_held() -> bool:
	return false


func jump_just_pressed() -> bool:
	return false


func jump_just_released() -> bool:
	return false


func crouch_held() -> bool:
	return false


func dash_just_pressed() -> bool:
	return false


func fire_held() -> bool:
	return false


func is_interact_event(_event: InputEvent) -> bool:
	return false


func is_launch_accept_event(_event: InputEvent) -> bool:
	return false


func get_movement_vector() -> Vector2:
	return Vector2.ZERO


func get_aim_world_position() -> Vector2:
	return Vector2.ZERO
