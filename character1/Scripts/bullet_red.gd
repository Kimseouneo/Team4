extends RigidBody2D

@export var gravity: float = 500.0
@export var power: float = 5.0   # 드래그 세기 조절 변수
# 화살표 길이 조절용 변수 (값이 클수록 화살표가 덜 늘어남)
@export var arrow_scale_damp: float = 50.0
var is_dragging := false
var start_pos := Vector2.ZERO
var drag_start := Vector2.ZERO
var is_exploding := false # 이미 폭wsd발a sda중인지 확인하는 변수
var initial_arrow_scale: Vector2
# $Bullet 쪽에 원하는 이미지 드래그해서 교체하면 이미지 변환 가능
@onready var sprite: Sprite2D = $Bullet
# AnimatedSprite2D 노드를 가져옵니다 (씬 트리에 노드 이름이 정확해야 합니다)
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
# 화살표 노드 연결
@onready var arrow_sprite: Sprite2D = $Arrow
# character의 global position 받기 위함
@onready var char_red : Node2D = get_parent()
@onready var turn_manager = $"../../TurnManager"
var active = false

func set_active(state: bool):
	active = state

func _ready():
	start_pos = global_position
	freeze = true
	gravity_scale = 0
	linear_velocity = Vector2.ZERO
	sprite.visible = false    # 처음엔 안 보이게 설정
	animated_sprite.visible = false # 폭발 애니메이션은 평소엔 숨김
	arrow_sprite.visible = false
	initial_arrow_scale = arrow_sprite.scale
	
	# [중요] RigidBody2D의 충돌 감지를 위해 필수적인 설정
	contact_monitor = true #충돌 감지 on
	max_contacts_reported = 1 #충돌 시 한번에 인식할 물체의 개수
	
	# 충돌 시그널 연결 (에디터에서 연결해도 되지만 코드로 하면 안전합니다)
	body_entered.connect(_on_body_entered)
	
func _input(event):
	# 폭발 중이면 입력 무시
	if not active or is_exploding: return
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				# 클릭 시작 → 드래그 시작
				is_dragging = true
				drag_start = event.position
				sprite.visible = false   # 드래그 중에는 숨김
				# [추가] 화살표 보이기 및 초기화
				arrow_sprite.visible = true
				update_arrow(event.position)
			else:
				# 드래그 종료 → 발사
				if is_dragging:
					is_dragging = false
					# 발사 시 화살표 숨김
					arrow_sprite.visible = false
					_fire(event.position)
					if turn_manager:
						turn_manager.next_turn()
	elif event is InputEventMouseMotion and is_dragging:
		update_arrow(event.position)

# 화살표의 회전과 길이를 계산하는 함수
func update_arrow(current_mouse_pos: Vector2):
	# 1. 드래그 벡터 계산 (시작점 - 현재 마우스 위치)
	# 마우스를 뒤로 당기면(왼쪽), 화살표는 앞으로(오른쪽) 나가야 하므로 순서 주의
	var aim_vector = drag_start - current_mouse_pos
	
	# 2. 회전: 벡터의 각도를 화살표에 적용
	arrow_sprite.rotation = aim_vector.angle()
	
	# 3. 길이(Scale): 드래그 거리에 비례해서 늘리기
	var drag_distance = aim_vector.length()
	
	# clamp 함수는 값을 최소~최대 사이로 고정해줍니다.
	# 1.0 = 원래 길이, 3.0 = 최대 3배까지 길어짐
	var stretch_ratio = clamp(drag_distance / arrow_scale_damp, 1.0, 3.0)
	
	# 화살표는 길이(x축)만 늘어남
	arrow_sprite.scale = Vector2(initial_arrow_scale.x * stretch_ratio, initial_arrow_scale.y)

func _fire(release_pos: Vector2):
	freeze = false
	gravity_scale = 1
	sprite.visible = true     # 드래그 끝나면 이미지 보이기 시작

	var drag_vector = release_pos - drag_start
	var launch_vector = -drag_vector * power
	linear_velocity = launch_vector
	print("Launch velocity:", linear_velocity)

func _physics_process(delta):
	if freeze:
		if char_red:
			global_position = char_red.global_position + Vector2(-50, -10)
		return
	# 폭발 중이거나 아직 발사 안했으면 물리 연산 중지
	if is_exploding: return
	# 중력 적용
	linear_velocity.y += gravity * delta

	# 포물선 접선 방향으로 회전
	if linear_velocity.length() > 0.1:
		rotation = linear_velocity.angle()
		
# 충돌 감지 함수
func _on_body_entered(_body: Node):
	# 이미 폭발 중이면 무시 (중복 충돌 방지)
	if is_exploding: return
	
	# 여기에 "플레이어 자신"과는 충돌하지 않게 하는 로직을 추가할 수도 있습니다.
	# 예: if body.name == "Player": return
	
	explode()

# 폭발 처리 함수
func explode():
	if is_exploding: return
	is_exploding = true
	
	# 화살표가 혹시 켜져있다면 확실히 끔
	arrow_sprite.visible = false
	
	# [중요] 물리 엔진이 계산 중일 때 속성을 바꾸면 무시될 수 있으므로
	# call_deferred 나 set_deferred를 사용해야 안전하게 멈춥니다.
	call_deferred("_stop_physics")
	
	# 이미지 교체
	sprite.visible = false
	animated_sprite.visible = true
	
	# 애니메이션 재생 (이제 Loop가 꺼져있어야 함)
	animated_sprite.play("explode")
	
	# 애니메이션 끝날 때까지 대기
	await animated_sprite.animation_finished
	
	# 총알 삭제
	queue_free()

# 물리 동작을 멈추는 함수를 따로 분리 (call_deferred로 호출됨)
func _stop_physics():
	freeze = true             # 위치 고정
	linear_velocity = Vector2.ZERO  # 속도 0
	angular_velocity = 0      # 회전 속도 0
	gravity_scale = 0         # 중력 영향 제거	
	# 혹시 모르니 물리 처리 프로세스도 끕니다
	set_physics_process(false)
