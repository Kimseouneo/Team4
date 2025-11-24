extends Node2D

@onready var ground: Polygon2D = $Ground
@onready var ground_collision: CollisionPolygon2D = $GroundBody/GroundCollision

func _ready() -> void:
	# Ground의 폴리곤 데이터를 CollisionPolygon2D에 그대로 복사
	ground_collision.polygon = ground.polygon
