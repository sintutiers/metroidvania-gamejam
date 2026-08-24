# facing_component.gd
class_name FacingComponent
extends Component

signal flipped(new_facing_x: float)

<<<<<<< HEAD
var facing: Vector2 = Vector2.DOWN
=======
@export var default_facing_right: bool = true

var facing: Vector2
>>>>>>> origin/main


func update(direction: Vector2) -> bool:
	if direction.is_zero_approx():
		return false
<<<<<<< HEAD

	var new_facing: Vector2 = Vector2(signf(direction.x), signf(direction.y))
	if (
		not is_zero_approx(new_facing.x) and not is_zero_approx(facing.x)
		and signf(new_facing.x) != signf(facing.x)
	):
		flipped.emit(new_facing.x)

	var changed: bool = new_facing != facing
	facing = new_facing
	return changed
=======
	var new_facing := facing
	if not is_zero_approx(direction.x):
		new_facing.x = signf(direction.x)
	if not is_zero_approx(direction.y):
		new_facing.y = signf(direction.y)
	if (not is_zero_approx(new_facing.x) and signf(new_facing.x) != signf(facing.x)):
		flipped.emit(new_facing.x)
	var changed: bool = new_facing != facing
	facing = new_facing
	return changed


func _on_setup() -> void:
	facing = Vector2(1.0 if default_facing_right else -1.0, -1.0)
>>>>>>> origin/main
