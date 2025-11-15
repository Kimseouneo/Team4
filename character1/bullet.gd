extends RigidBody2D

@export var gravity: float = 500.0
@export var power: float = 5.0   # 드래그 세기 조절 변

var is_dragging := false
var start_pos := Vector2.ZERO
var drag_start := Vector2.ZERO
# $Bullet 쪽에 원하는 이미지 드래그해서 교체하면 이미지 변환 가능
@onready var sprite: Sprite2D = $Bullet   
func _ready():
	start_pos = global_position
	freeze = true
	gravity_scale = 0
	linear_velocity = Vector2.ZERO
	sprite.visible = false    # 처음엔 안 보이게 설정

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				# 클릭 시작 → 드래그 시작
				is_dragging = true
				drag_start = event.position
				sprite.visible = false   # 드래그 중에는 숨김
			else:
				# 드래그 종료 → 발사
				if is_dragging:
					is_dragging = false
					_fire(event.position)
	elif event is InputEventMouseMotion and is_dragging:
		pass  # 드래그 선 시각화 가능

func _fire(release_pos: Vector2):
	freeze = false
	gravity_scale = 1
	sprite.visible = true     # 드래그 끝나면 이미지 보이기 시작

	var drag_vector = release_pos - drag_start
	var launch_vector = -drag_vector * power
	linear_velocity = launch_vector
	print("Launch velocity:", linear_velocity)

func _physics_process(delta):
	# 중력 적용
	linear_velocity.y += gravity * delta

	# 포물선 접선 방향으로 회전
	if linear_velocity.length() > 0.1:
		rotation = linear_velocity.angle()
