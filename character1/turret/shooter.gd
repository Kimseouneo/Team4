extends StaticBody2D

@export var bullet_scene: PackedScene
@export var fire_interval: float = 1.0

@onready var muzzle: Marker2D = $Muzzle
@onready var fire_timer: Timer = $FireTimer
@onready var sprite: Sprite2D = $Sprite2D   # 필요하면 사용

func _ready() -> void:
	fire_timer.wait_time = fire_interval
	fire_timer.timeout.connect(_on_fire_timer_timeout)

func _on_fire_timer_timeout() -> void:
	if bullet_scene == null:
		return

	var bullet = bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet)

	bullet.global_position = muzzle.global_position
	var dir: Vector2 = muzzle.global_transform.x.normalized()
	bullet.direction = dir
