# Bullet.gd
extends Area2D
@export var speed: float = 400.0
var direction: Vector2 = Vector2.LEFT

func _ready():
	body_entered.connect(_on_body_entered)
	monitoring = true
	monitorable = true

func _physics_process(delta: float):
	position += direction * speed * delta

func _on_body_entered(body:Node):
	if body.name=="char_silver":
		body.take_damage(1)
	queue_free()
