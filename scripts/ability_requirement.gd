class_name AbilityRequirement
extends GateRequirement

@export var ability_id: StringName
@export var min_level: int = 1


func is_met(player: Node) -> bool:
	var ability := Component.find_component(player, AbilityComponent, false) as AbilityComponent
	return ability and ability.get_level(ability_id) >= min_level
