extends StaticBody2D

@export var bullet_scene: PackedScene
@export var fire_interval: float = 1.0
@export var max_hits = 3

@onready var muzzle: Marker2D = $Muzzle
@onready var fire_timer: Timer = $FireTimer

var hits = 0 # 탄을 맞으면 1회씩 증가

func _ready():
	hits = 0
	fire_timer.wait_time = fire_interval
	fire_timer.one_shot = false        # 반복 발사
	fire_timer.timeout.connect(_on_fire_timer_timeout)
	fire_timer.start()                 # 타이머 시작

func _on_fire_timer_timeout():
	if bullet_scene == null:
		return

	var bullet = bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet)

	# 총알 생성 위치
	bullet.global_position = muzzle.global_position

	# 발사 방향 (Muzzle의 x축 기준)
	var dir: Vector2 = muzzle.global_transform.x.normalized()
	bullet.direction = -dir


func _on_bullet_silver_body_entered(body):
	if body.name == "Turret2":
		hits += 1
		if hits >= max_hits:
			queue_free()			
