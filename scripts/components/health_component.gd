class_name HealthComponent
extends Component

signal damaged(amount: float, source: Node)
signal healed(amount: float)
signal died

@export var max_health: float = 100.0
@export var current_health: float = 100.0


func take_damage(amount: float, source: Node = null) -> void:
	if current_health <= 0.0 or amount <= 0.0:
		return
	current_health = maxf(current_health - amount, 0.0)
	damaged.emit(amount, source)
	if current_health <= 0.0:
		died.emit()


func heal(amount: float) -> void:
	if current_health <= 0.0 or amount <= 0.0:
		return
	current_health = minf(current_health + amount, max_health)
	healed.emit(amount)


func is_dead() -> bool:
	return current_health <= 0.0
