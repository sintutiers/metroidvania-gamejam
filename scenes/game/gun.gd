class_name Gun
extends Component

@onready var sprite: Sprite2D = %Muzzle as Sprite2D


func set_visual(texture: Texture2D) -> void:
	sprite.texture = texture
