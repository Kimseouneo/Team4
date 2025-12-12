extends CharacterBody2D

@onready var target = $"../char_silver"
@export var follow_speed: float = 150.0

func _physics_process(delta):
	if target == null:
		return

	# --- 타겟을 향하는 방향 벡터 계산 ---
	var direction = (target.global_position - global_position).normalized()
	velocity = direction * follow_speed

	# --- 타겟을 바라보도록 회전 ---
	rotation = direction.angle()

	# --- 이동 및 충돌 감지 ---
	var collision = move_and_collide(velocity * delta)

	if collision:
		var body = collision.get_collider()
		if body and body.name == "char_silver":
			if body.has_method("take_damage"):
				body.take_damage(1)
			queue_free()
