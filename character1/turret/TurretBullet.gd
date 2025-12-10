# Bullet.gd
extends Area2D

@export var speed: float = 400.0
var direction: Vector2 = Vector2.LEFT

func _physics_process(delta: float) -> void:
	position += direction * speed * delta

func _on_body_entered(body: Node) -> void:
	queue_free()
