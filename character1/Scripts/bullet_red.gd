extends RigidBody2D

@export var gravity: float = 500.0
@export var power: float = 5.0   # 드래그 세기 조절 변수
# 화살표 길이 조절용 변수 (값이 클수록 화살표가 덜 늘어남)
@export var arrow_scale_damp: float = 50.0
var is_dragging := false
var start_pos := Vector2.ZERO
var drag_start := Vector2.ZERO
var is_exploding := false # 이미 폭발 	중인지 확인하는 변수
var initial_arrow_scale: Vector2
# $Bullet 쪽에 원하는 이미지 드래그해서 교체하면 이미지 변환 가능
@onready var sprite: Sprite2D = $Bullet
# AnimatedSprite2D 노드를 가져옵니다 (씬 트리에 노드 이름이 정확해야 합니다)
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
# 화살표 노드 연결
@onready var arrow_sprite: Sprite2D = $Arrow
# character의 global position 받기 위함
@onready var char_red : Node2D = get_parent()
@onready var turn_manager = $"../../Turnmanager"
@onready var collision_shape = $CollisionShape2D  # bullet의 충돌 모양 노드
var active = false

func set_active(state: bool):
	active = state

func _ready():
	start_pos = global_position
	freeze = true
	gravity_scale = 0
	sprite.visible = false
	animated_sprite.visible = false
	arrow_sprite.visible = false
	initial_arrow_scale = arrow_sprite.scale
	contact_monitor = true
	max_contacts_reported = 1
	body_entered.connect(_on_body_entered)
	
func _input(event):
	# 폭발 중이면 입력 무시
	if not active or is_exploding:
		return
	
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
	elif event is InputEventMouseMotion and is_dragging:
		update_arrow(event.position)

# 화살표의 회전과 길이를 계산하는 함수, silver와 좌우 대
func update_arrow(current_mouse_pos: Vector2):
	var aim_vector = Vector2(-(current_mouse_pos.x - drag_start.x), current_mouse_pos.y - drag_start.y)
	
	# 2. 회전: 벡터의 각도를 화살표에 적용
	arrow_sprite.rotation = aim_vector.angle() + PI
	
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
	#0.2초간 충돌 방지
	collision_shape.disabled = true
	await get_tree().create_timer(0.2).timeout
	collision_shape.disabled = false

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
func _on_body_entered(body: Node):
	if is_exploding:
		return
	
	if body.name == "Ground":
		explode()
	if body.name == "char_red" or "char_silver":
		explode()
	explode()

# 폭발 처리 함수
func explode():
	if is_exploding:
		return
	is_exploding = true
	var collision_pos = global_position #충돌 지점 저장
	arrow_sprite.visible = false
	sprite.visible = false
	
	var explosion = AnimatedSprite2D.new()
	explosion.sprite_frames = animated_sprite.sprite_frames
	explosion.animation = "explode"
	explosion.global_position = collision_pos
	explosion.play()
	get_tree().current_scene.add_child(explosion) 


	# 폭발 애니메이션 끝까지 기다린 후
	await explosion.animation_finished

	explosion.queue_free()
	stop_bullet()

	# 턴 전환
	if turn_manager and active:
		active = false  # 비활성화
		print(">>> Bullet exploded! Passing turn...")
		turn_manager.next_turn()


func stop_bullet():
	is_exploding = false
	freeze = true
	gravity_scale = 0
	linear_velocity = Vector2.ZERO
	rotation = 0
	sprite.visible = false
	animated_sprite.visible = false
	arrow_sprite.visible = false	
	if char_red:
		global_position = char_red.global_position + Vector2(-50, -10)
		start_pos = global_position

func _stop_physics():
	freeze = true             # 위치 고정
	linear_velocity = Vector2.ZERO  # 속도 0
	angular_velocity = 0      # 회전 속도 0
	gravity_scale = 0         # 중력 영향 제거	
	# 혹시 모르니 물리 처리 프로세스도 끕니다
	set_physics_process(false)
