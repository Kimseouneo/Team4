extends StaticBody2D

@export var bullet_scene: PackedScene
@export var fire_interval: float = 1.0

@onready var muzzle: Marker2D = $Muzzle
@onready var fire_timer: Timer = $FireTimer

func _ready():
	fire_timer.wait_time = fire_interval
	fire_timer.one_shot = false        # 반복 발사
	fire_timer.timeout.connect(_on_fire_timer_timeout)
	fire_timer.start()                 # ← 타이머 자동 시작

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
