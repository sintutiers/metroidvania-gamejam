# facing_component.gd
class_name FacingComponent
extends Component

signal flipped(new_facing_x: float)

var facing: Vector2 = Vector2.DOWN


func update(direction: Vector2) -> bool:
	if direction.is_zero_approx():
		return false

	var new_facing: Vector2 = Vector2(signf(direction.x), signf(direction.y))
	if (
		not is_zero_approx(new_facing.x) and not is_zero_approx(facing.x)
		and signf(new_facing.x) != signf(facing.x)
	):
		flipped.emit(new_facing.x)

	var changed: bool = new_facing != facing
	facing = new_facing
	return changed
