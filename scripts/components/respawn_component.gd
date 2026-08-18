# respawn_component.gd
class_name RespawnComponent
extends Component

signal respawned

var is_respawning: bool = false

@onready var body: CharacterBody2D = get_parent() as CharacterBody2D


func fall_and_respawn(respawn_position: Vector2) -> void:
	if is_respawning:
		return
	is_respawning = true
	body.velocity = Vector2.ZERO
	body.global_position = respawn_position
	is_respawning = false
	respawned.emit()
