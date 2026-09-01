class_name Gun
extends Component

@onready var sprite: Sprite2D = %GunSprite


func set_visual(texture: Texture2D, scale_value: Vector2 = Vector2.ONE) -> void:
	sprite.texture = texture
	sprite.scale = scale_value
