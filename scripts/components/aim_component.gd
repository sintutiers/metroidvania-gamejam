class_name AimComponent
extends Component

signal aimed(direction: Vector2)

@export var turn_speed: float = 5.0
@export var orbit_radius: float = 12.0

var aim_angle: float = 0.0

@onready var gun: Node2D = get_parent() as Node2D
@onready var muzzle: Node2D = %Muzzle


func _physics_process(delta: float) -> void:
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	var target: Vector2 = get_viewport().get_canvas_transform().affine_inverse() * mouse_pos
	var dir: Vector2 = target - gun.get_parent().global_position

	if dir.length_squared() <= 0.000001:
		return

	aim_angle = lerp_angle(aim_angle, dir.angle(), turn_speed * delta)
	gun.position = Vector2.from_angle(aim_angle) * orbit_radius
	gun.rotation = aim_angle
	aimed.emit(Vector2.from_angle(aim_angle))


func _on_ready() -> void:
	aim_angle = gun.rotation
