extends CharacterBody2D

@onready var target = $"../char_silver"
@export var follow_speed: float = 150.0
@export var life_time: float = 5.0  # 🔹 살아있는 시간 (초)

var elapsed_time := 0.0
var life_time_table := {
	"Bet": 3.0,
	"Bet2": 5.0,
	"Bet3": 8.0
}

func _ready():
	# 이름에 맞는 생존 시간 설정
	if life_time_table.has(name):
		life_time = life_time_table[name]
		
func _physics_process(delta):
	# 🔹 수명 체크
	elapsed_time += delta
	if elapsed_time >= life_time:
		queue_free()
		return

	if target == null:
		return

	# 타겟 방향
	var direction = (target.global_position - global_position).normalized()
	velocity = direction * follow_speed

	# 회전
	rotation = direction.angle()

	# 이동 및 충돌
	var collision = move_and_collide(velocity * delta)
	if collision:
		var body = collision.get_collider()
		if body and body.name == "char_silver":
			if body.has_method("take_damage"):
				body.take_damage(1)
		queue_free()
