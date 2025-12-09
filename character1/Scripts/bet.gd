extends CharacterBody2D

@onready var target =  $"../char_silver" #캐릭터를 직접 할당
@export var follow_speed: float = 150.0
@export var remove_distance: float = 60.0

func _physics_process(delta):
	if target == null:
		return

	# 캐릭터의 중심을 따라감
	var target_pos = target.global_position

	var direction = target_pos - global_position
	var distance = direction.length()

	# 너무 가까우면 삭제
	if distance < remove_distance:
		queue_free()
		return

	velocity = direction.normalized() * follow_speed
	move_and_slide()
