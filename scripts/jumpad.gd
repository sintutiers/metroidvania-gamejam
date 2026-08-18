class_name Launchpad
extends Area2D

@export var direction: Vector2 = Vector2.UP
@export var speed: float = 1200.0
@export var distance: float = 300.0
@export var require_input: bool = false

var _target: LaunchComponent


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node2D) -> void:
	_target = Component.find_component(body, LaunchComponent) as LaunchComponent
	if not _target:
		return
	if require_input:
		_target.register_pad(direction, speed, distance)
	else:
		_target.launch(direction, speed, distance)


func _on_body_exited(_body: Node2D) -> void:
	if _target:
		_target.clear_pad()
	_target = null
