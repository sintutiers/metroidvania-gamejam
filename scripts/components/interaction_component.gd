# interaction_component.gd
class_name InteractionComponent
extends Component

<<<<<<< HEAD
@export var interact_radius: float = 32.0

var interact_area: Area2D

@onready var body: CharacterBody2D = get_parent() as CharacterBody2D
@onready var state_chart: StateChart = %StateChart


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_select"):
=======
@export_custom(ETP.NONE, ETP.PROPERTY)
var interact_radius: float = 32.0

var interact_area: Area2D
var input_component: InputComponent
var state_chart: StateChart
var interact_component: InteractComponent

@onready var body: CharacterBody2D = get_parent() as CharacterBody2D


func _unhandled_input(event: InputEvent) -> void:
	if interact_component and interact_component.is_locked:
		return
	if input_component.is_interact_event(event):
>>>>>>> origin/main
		interact()


func interact() -> void:
	var closest: InteractableThing = null
	var closest_dist_sq: float = INF
	var player_pos: Vector2 = body.global_position
	for interactable: InteractableThing in get_tree().get_nodes_in_group(&"interactable"):
		var dist_sq: float = player_pos.distance_squared_to(interactable.global_position)
		if dist_sq > interact_radius * interact_radius:
			continue
		if dist_sq < closest_dist_sq:
			closest_dist_sq = dist_sq
			closest = interactable
	if not closest:
		return
	closest.trigger(interact_area)
<<<<<<< HEAD
	state_chart.send_event(&"interact")
=======
	if state_chart:
		state_chart.send_event(StateEvents.INTERACT)
>>>>>>> origin/main
	if closest.holds_interact_lock:
		closest.interaction_finished.connect(_end_interact, CONNECT_ONE_SHOT)
	else:
		_end_interact()


func _on_setup() -> void:
	interact_area = get_component(Area2D, false) as Area2D
<<<<<<< HEAD


func _end_interact() -> void:
	state_chart.send_event(&"interact_end")
=======
	input_component = get_component(InputComponent) as InputComponent
	state_chart = get_component(StateChart, false) as StateChart
	interact_component = get_component(InteractComponent, false) as InteractComponent


func _end_interact() -> void:
	if state_chart:
		state_chart.send_event(StateEvents.INTERACT_END)
>>>>>>> origin/main
