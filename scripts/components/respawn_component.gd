# respawn_component.gd
class_name RespawnComponent
extends Component

signal respawned

<<<<<<< HEAD
var is_respawning: bool = false
=======
@export_custom(ETP.NONE, ETP.PROPERTY)
var respawn_heal_amount: int = 0
@export_custom(ETP.NONE, ETP.PROPERTY)
var heal_on_respawn: bool = true

var is_respawning: bool = false
var reset_position: Vector2

var _health: Health
>>>>>>> origin/main

@onready var body: CharacterBody2D = get_parent() as CharacterBody2D


<<<<<<< HEAD
=======
func mark_room_entry_point() -> void:
	reset_position = body.global_position


>>>>>>> origin/main
func fall_and_respawn(respawn_position: Vector2) -> void:
	if is_respawning:
		return
	is_respawning = true
	body.velocity = Vector2.ZERO
	body.global_position = respawn_position
	is_respawning = false
	respawned.emit()
<<<<<<< HEAD
=======
	if heal_on_respawn and _health:
		if respawn_heal_amount <= 0:
			_health.fill()
		else:
			_health.heal(respawn_heal_amount)


func _on_setup() -> void:
	_health = get_component(Health, false) as Health
	if _health:
		track(_health.died, _on_died)


func _on_died(_entity: Node) -> void:
	fall_and_respawn(reset_position if reset_position else body.global_position)
>>>>>>> origin/main
