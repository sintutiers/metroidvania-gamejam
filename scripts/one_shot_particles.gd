# one_shot_particles.gd
extends CPUParticles2D


func _ready() -> void:
	one_shot = true
	emitting = true
	finished.connect(queue_free)
