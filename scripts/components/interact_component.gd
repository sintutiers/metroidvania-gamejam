#interact_component.gd
class_name InteractComponent
extends Component

signal interact_started
signal interact_ended

@onready var interact_state: StateChartState = %Interact


func _on_ready() -> void:
	interact_state.state_entered.connect(interact_started.emit)
	interact_state.state_exited.connect(interact_ended.emit)
