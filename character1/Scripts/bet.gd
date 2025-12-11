extends CharacterBody2D

@onready var target = $"../char_silver"
@export var follow_speed: float = 150.0

func _physics_process(delta):
	if target == null:
		return

	var direction = (target.global_position - global_position).normalized()
	velocity = direction * follow_speed

	# move_and_collide를 사용해 충돌 감지
	var collision = move_and_collide(velocity * delta)

	if collision:
		var body = collision.get_collider()
		if body and body.name == "char_silver":
			if body.has_method("take_damage"):
				body.take_damage(1)
			queue_free()
