class_name Portal
extends Area2D

enum PickupMode {
	ON_INTERACT,
	ON_OVERLAP,
}

@export var pickup_mode: PickupMode = PickupMode.ON_OVERLAP
@export var portal_id: StringName
@export var target_portal_id: StringName


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	if pickup_mode == PickupMode.ON_INTERACT:
		var interactable := Component.find_component(self, InteractableThing, false) as InteractableThing
		if interactable:
			interactable.interacted.connect(_on_interacted)
		else:
			push_warning("Portal: ON_INTERACT set but no InteractableThing found.")


func _on_body_entered(body: Node2D) -> void:
	if pickup_mode != PickupMode.ON_OVERLAP:
		return
	_try_enter(body)


func _on_interacted(by: Area2D) -> void:
	var body := by.get_parent() if by else get_tree().get_first_node_in_group(&"player")
	_try_enter(body)


func _try_enter(body: Node2D) -> void:
	if not body or not body.is_in_group(&"player") or body.event:
		print("Portal: blocked, body=", body, " event=", body.event if body else "n/a")
		return
	body.event = true

	var target: Portal = _find_portal_by_id(get_tree().root, target_portal_id)
	print("Portal: looking for target_id=", target_portal_id, " found=", target)
	if target:
		_move_and_finish(body, target)
		return

	var target_scene: String = LevelAndStateManager.get_scene_for_portal(target_portal_id)
	if target_scene.is_empty():
		push_warning(
			"Portal: '%s' not found in any loaded or previously visited room." % target_portal_id
		)
		body.event = false
		return

	Game.get_singleton().room_loaded.connect(_on_room_loaded.bind(body), CONNECT_ONE_SHOT)
	Game.get_singleton().load_room(target_scene)


func _on_room_loaded(body: Node2D) -> void:
	var tree := body.get_tree()
	if not tree:
		return
	var target: Portal = _find_portal_by_id(tree.root, target_portal_id)
	if not target:
		push_warning("Portal: '%s' not found after loading target room." % target_portal_id)
		body.event = false
		return
	_move_and_finish(body, target)


func _move_and_finish(body: Node2D, target: Portal) -> void:
	Game.get_singleton().player.position = target.position
	body.get_tree().create_timer(0.1).timeout.connect(
		func() -> void:
			body.event = false,
	)


func _find_portal_by_id(root: Node, id: StringName) -> Portal:
	for child: Node in root.get_children():
		if child is Portal and child.portal_id == id:
			return child
		var found := _find_portal_by_id(child, id)
		if found:
			return found
	return null
