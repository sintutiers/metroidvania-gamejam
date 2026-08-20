#attack_component
class_name AttackComponent
extends Component

signal fired
signal aim_started
signal aim_ended

@export var weapon: WeaponResource

var _fire_cooldown: float = 0.0
var _was_aiming: bool = false

@onready var muzzle: Node2D = %Muzzle


func _physics_process(delta: float) -> void:
	if _fire_cooldown > 0.0:
		_fire_cooldown -= delta

	var holding_fire: bool = Input.is_action_pressed("fire")
	if holding_fire:
		_try_fire()

	var is_aiming: bool = holding_fire and _fire_cooldown > 0.0
	if is_aiming and not _was_aiming:
		aim_started.emit()
	elif not is_aiming and _was_aiming:
		aim_ended.emit()
	_was_aiming = is_aiming


func _try_fire() -> void:
	if not weapon or not weapon.behavior or _fire_cooldown > 0.0:
		return
	_fire_cooldown = weapon.fire_rate
	weapon.behavior.fire(self, muzzle)
	fired.emit()
