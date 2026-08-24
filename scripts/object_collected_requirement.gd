class_name ObjectCollectedRequirement
extends GateRequirement

@export var object_id: StringName
@export var source_path: NodePath


func is_met(_player: Node) -> bool:
	return MetSys.is_object_id_stored(object_id)


func setup(gate: Node) -> void:
	var source := gate.get_node_or_null(source_path) as CollectibleObject
	if source:
		source.collected.connect(_on_collected)


func _on_collected() -> void:
	requirement_changed.emit()
