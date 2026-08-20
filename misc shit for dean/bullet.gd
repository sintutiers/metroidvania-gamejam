class_name Bullet
extends Area2D

@export var speed: float = 600.0
@export var lifetime: float = 3.0

var damage: float = 10.0


func _ready() -> void:
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)
	get_tree().create_timer(lifetime).timeout.connect(queue_free)


func _physics_process(delta: float) -> void:
	position += transform.x * speed * delta


func _on_area_entered(area: Area2D) -> void:
	_hit(area)


func _on_body_entered(body: Node) -> void:
	_hit(body)


func _hit(target: Node) -> void:
	queue_free()
