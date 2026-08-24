@tool
extends PhantomCamera2D


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	var player := get_tree().get_first_node_in_group(&"player")
	if player:
		follow_target = player
