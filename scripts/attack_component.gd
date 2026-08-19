class_name AttackComponent
extends Component

@export var weapon: WeaponResource

var _fire_cooldown: float = 0.0

@onready var muzzle: Node2D = %Muzzle


func _physics_process(delta: float) -> void:
	if _fire_cooldown > 0.0:
		_fire_cooldown -= delta
	if Input.is_action_pressed("fire"):
		_try_fire()


func _try_fire() -> void:
	if not weapon or not weapon.behavior or _fire_cooldown > 0.0:
		return
	_fire_cooldown = weapon.fire_rate
	weapon.behavior.fire(self, muzzle)
