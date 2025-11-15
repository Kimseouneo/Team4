extends RigidBody2D
@export var health := 10
@onready var body_sprite: Sprite2D = $Body

@export var normal_texture: Texture2D
@export var mid_damage_texture: Texture2D
@export var heavy_damage_texture: Texture2D

func _ready():
	# 초기 텍스처 세팅
	body_sprite.texture = normal_texture
	
func take_damage(amount: int):
	health = max(health - amount, 0)
	_update_body_texture()

func _update_body_texture():
	if health > 6:
		body_sprite.texture = normal_texture
	elif health > 3:
		body_sprite.texture = mid_damage_texture
	else:
		body_sprite.texture = heavy_damage_texture
