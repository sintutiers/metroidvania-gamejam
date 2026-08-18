# interactable_thing.gd
class_name InteractableThing
extends Node2D

signal interacted(by: Area2D)
signal interaction_finished

@export var animate_on_interact: bool = false
@export var holds_interact_lock: bool = false
@export var sprite: AnimatedSprite2D


func _ready() -> void:
	add_to_group(&"interactable")
	if animate_on_interact:
		if sprite:
			sprite.pause()
		else:
			push_warning("No sprite.")


func trigger(by: Area2D) -> void:
	if animate_on_interact and sprite:
		sprite.play()
	interacted.emit(by)


func finish_interaction() -> void:
	interaction_finished.emit()
