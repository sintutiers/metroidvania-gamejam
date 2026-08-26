class_name PlayerInputComponent
extends InputComponent


<<<<<<< HEAD
=======
func get_movement_vector() -> Vector2:
	return Input.get_vector("move_left", "move_right", "move_up", "move_down")


func get_aim_world_position() -> Vector2:
	var mouse_pos := get_viewport().get_mouse_position()
	return get_viewport().get_canvas_transform().affine_inverse() * mouse_pos


>>>>>>> origin/main
func move_axis() -> float:
	return Input.get_axis("move_left", "move_right")


func run_held() -> bool:
	return Input.is_action_pressed("run")


func jump_just_pressed() -> bool:
	return Input.is_action_just_pressed("jump")


func jump_just_released() -> bool:
	return Input.is_action_just_released("jump")


func crouch_held() -> bool:
	return Input.is_action_pressed("crouch")


func dash_just_pressed() -> bool:
	return Input.is_action_just_pressed("dash")


func fire_held() -> bool:
	return Input.is_action_pressed("fire")


func is_interact_event(event: InputEvent) -> bool:
	return event.is_action_pressed("ui_select")


func is_launch_accept_event(event: InputEvent) -> bool:
	return event.is_action_pressed("ui_accept")
<<<<<<< HEAD
=======


func _on_ready() -> void:
	get_parent().add_to_group(&"player")
>>>>>>> origin/main
