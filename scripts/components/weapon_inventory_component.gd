class_name WeaponInventoryComponent
extends Component

signal weapon_changed(weapon: WeaponResource)

@export var starting_weapons: Array[WeaponResource] = []

var owned_weapons: Array[WeaponResource] = []
var current_index: int = 0

var input_component: InputComponent


func _unhandled_input(event: InputEvent) -> void:
	if owned_weapons.size() <= 1:
		return
	if input_component.is_weapon_next_event(event):
		_cycle(1)
	elif input_component.is_weapon_prev_event(event):
		_cycle(-1)


func current_weapon() -> WeaponResource:
	return owned_weapons[current_index] if not owned_weapons.is_empty() else null


func add_weapon(weapon: WeaponResource) -> void:
	if weapon in owned_weapons:
		return
	owned_weapons.append(weapon)
	current_index = owned_weapons.size() - 1
	weapon_changed.emit(current_weapon())


func _on_setup() -> void:
	input_component = get_component(InputComponent) as InputComponent
	owned_weapons = starting_weapons.duplicate()
	if not owned_weapons.is_empty():
		weapon_changed.emit(current_weapon())


func _cycle(delta: int) -> void:
	current_index = wrapi(current_index + delta, 0, owned_weapons.size())
	weapon_changed.emit(current_weapon())
