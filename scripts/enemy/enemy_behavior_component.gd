class_name EnemyBehaviorComponent
extends MovementBase

enum State {
	PATROL,
	CHASE,
	ATTACK,
}

@export_group("Patrol")
@export_custom(ETP.NONE, ETP.PROPERTY)
var patrol_speed: float = 60.0

@export_group("Chase")
@export_custom(ETP.NONE, ETP.PROPERTY)
var chase_speed: float = 120.0
@export_custom(ETP.NONE, ETP.PROPERTY)
var detection_radius: float = 150.0
@export_custom(ETP.NONE, ETP.PROPERTY)
var lose_radius: float = 220.0

@export_group("Attack")
@export_custom(ETP.NONE, ETP.PROPERTY)
var attack_range: float = 24.0
@export_custom(ETP.NONE, ETP.PROPERTY)
var attack_cooldown: float = 1.0

var state: State = State.PATROL

var facing_component: FacingComponent
var _direction: float = 1.0
var _player: Node2D
var _attack_timer: float = 0.0

@onready var body: CharacterBody2D = get_parent() as CharacterBody2D
@onready var wall_check: RayCast2D = %WallCheck
@onready var ledge_check: RayCast2D = %LedgeCheck
@onready var base_gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta: float) -> void:
	if _attack_timer > 0.0:
		_attack_timer -= delta

	_player = get_tree().get_first_node_in_group(&"player")

	match state:
		State.PATROL:
			_patrol(delta)
		State.CHASE:
			_chase(delta)
		State.ATTACK:
			_attack(delta)

	body.velocity.y += base_gravity * delta
	body.move_and_slide()


func _on_setup() -> void:
	facing_component = get_component(FacingComponent, false) as FacingComponent


func _patrol(delta: float) -> void:
	if wall_check.is_colliding() or not ledge_check.is_colliding():
		_direction *= -1.0
	_set_facing(_direction)
	body.velocity.x = _direction * patrol_speed

	if _player and body.global_position.distance_to(_player.global_position) <= detection_radius:
		state = State.CHASE


func _chase(delta: float) -> void:
	if not _player:
		state = State.PATROL
		return

	var dist: float = body.global_position.distance_to(_player.global_position)
	if dist > lose_radius:
		state = State.PATROL
		return
	if dist <= attack_range:
		state = State.ATTACK
		return

	_direction = signf(_player.global_position.x - body.global_position.x)
	_set_facing(_direction)
	body.velocity.x = _direction * chase_speed


func _attack(_delta: float) -> void:
	body.velocity.x = 0.0
	if not _player:
		state = State.PATROL
		return
	if body.global_position.distance_to(_player.global_position) > attack_range:
		state = State.CHASE
		return
	if _attack_timer <= 0.0:
		_attack_timer = attack_cooldown


func _set_facing(dir: float) -> void:
	if facing_component:
		var changed := facing_component.update(Vector2(dir, 0.0))
		if changed:
			moved.emit(facing_component.facing)
