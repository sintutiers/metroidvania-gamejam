@tool
extends PhantomCamera2D

@export_custom(ETP.NONE, ETP.PROPERTY)
var shake_decay_per_second: float = 5.0
@export_custom(ETP.NONE, ETP.PROPERTY)
var shake_trauma_power: float = 2.0
@export_custom(ETP.NONE, ETP.PROPERTY)
var shake_max_offset: Vector2 = Vector2(12.0, 8.0)
@export_custom(ETP.NONE, ETP.PROPERTY)
var shake_max_roll: float = 0.05
@export_custom(ETP.NONE, ETP.PROPERTY)
var shake_noise_speed: float = 20.0

var _trauma: float = 0.0
var _noise: FastNoiseLite = FastNoiseLite.new()
var _noise_t: float = 0.0


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	var player := get_tree().get_first_node_in_group(&"player")
	if player:
		follow_target = player
	_noise.seed = randi()
	_noise.frequency = 1.0


func _process(delta: float) -> void:
	if Engine.is_editor_hint() or _trauma <= 0.0:
		return

	_noise_t += delta * shake_noise_speed
	var shake: float = pow(_trauma, shake_trauma_power)

	var offset_x: float = shake_max_offset.x * shake * _noise.get_noise_2d(_noise_t, 0.0)
	var offset_y: float = shake_max_offset.y * shake * _noise.get_noise_2d(0.0, _noise_t)
	var roll: float = shake_max_roll * shake * _noise.get_noise_2d(_noise_t, _noise_t)

	emit_noise(Transform2D(roll, Vector2(offset_x, offset_y)))

	_trauma = maxf(_trauma - shake_decay_per_second * delta, 0.0)


func add_trauma(amount: float) -> void:
	_trauma = clampf(_trauma + amount, 0.0, 1.0)
