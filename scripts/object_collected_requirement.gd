class_name ObjectCollectedRequirement
extends GateRequirement

@export var object_id: StringName
@export var source_path: NodePath


func is_met(_player: Node) -> bool:
	return MetSys.is_object_id_stored(object_id)
