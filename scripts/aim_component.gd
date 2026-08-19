class_name AimComponent
extends Component

signal aimed(direction: Vector2)

@export var turn_speed: float = 5.0
@export var max_turn_degrees: float = 80.0

var aim_angle: float = 0.0
var aim_side: float = 1.0

@onready var body: Node2D = get_parent() as Node2D
@onready var sprite: Node2D = %AnimatedSprite2D


func _physics_process(delta: float) -> void:
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	var target: Vector2 = get_viewport().get_canvas_transform().affine_inverse() * mouse_pos
	var dir: Vector2 = target - body.global_position

	if dir.length_squared() <= 0.000001:
		return

	if aim_side >= 0.0 and dir.x < 0.0:
		aim_side = -1.0
	elif aim_side < 0.0 and dir.x > 0.0:
		aim_side = 1.0

	var flat_dir: Vector2 = Vector2(absf(dir.x), dir.y)
	var base_angle: float = clamp(
		flat_dir.angle(),
		-deg_to_rad(max_turn_degrees),
		deg_to_rad(max_turn_degrees),
	)
	var target_angle: float = base_angle * aim_side

	aim_angle = lerp_angle(aim_angle, target_angle, turn_speed * delta)
	body.global_rotation = aim_angle
	sprite.scale.x = aim_side * absf(sprite.scale.x)

	aimed.emit(Vector2.from_angle(aim_angle))


func _on_ready() -> void:
	aim_angle = body.global_rotation
