extends RigidBody2D

@export var tile_size: int=32 #타일 사이즈 설정
@export var explosion_radius_px:float=64.0 #반지름 설정
@export var map_layer:TileMapLayer
@export var gravity: float = 500.0
@export var power: float = 5.0
@export var arrow_scale_damp: float = 50.0

var is_dragging := false
var drag_start := Vector2.ZERO
var is_exploding := false
var initial_arrow_scale: Vector2
var start_pos := Vector2.ZERO
@onready var sprite: Sprite2D = $Bullet
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var arrow = $Arrow2
@onready var collision_shape = $CollisionShape2D
@onready var char_owner: Node2D = get_parent()
@onready var turn_manager: Node = $"../../Turnmanager"
@onready var anchor : Node2D = get_parent().get_node("Anchor")
@onready var Target = $"../../Target"
var can_drag := true  # 드래그 활성화
var active = false #초기에는 비활성화

func destroy_tiles_around_explosion():
	if map_layer==null:
		return
	# 1) 총알의 global_position을 Map 기준 로컬 좌표로 변환
	var local_pos: Vector2 = map_layer.to_local(global_position)

	# 2) 로컬 좌표를 타일 좌표(셀 좌표)로 변환
	var center_cell: Vector2i = map_layer.local_to_map(local_pos)

	# 3) 폭발 반경(픽셀)을 타일 개수(반경)로 변환
	var radius_in_tiles: int = int(ceil(explosion_radius_px / float(tile_size)))
	
	# 4) 원형 영역 안에 있는 타일들 지우기
	for y in range(-radius_in_tiles, radius_in_tiles + 1):
		for x in range(-radius_in_tiles, radius_in_tiles + 1):
			var offset: Vector2 = Vector2(x, y)
		
			# offset 길이(타일 단위)를 픽셀 단위로 환산해서 원 안인지 체크
			if offset.length() * float(tile_size) <= explosion_radius_px:
				var cell: Vector2i = center_cell + Vector2i(x, y)
			
			# 그 칸에 타일이 실제로 있는지 확인
				var tile_data := map_layer.get_cell_tile_data(cell)
				if tile_data != null:
					# 타일 삭제
					map_layer.erase_cell(cell)

func set_active(state):
	active = state
	if state:
		can_drag = true

func _ready():
	start_pos = global_position # 탄 시작 지점 저장
	freeze = true
	gravity_scale = 0
	sprite.visible = false
	animated_sprite.visible = false
	arrow.visible = false
	initial_arrow_scale = arrow.scale
	contact_monitor = true
	max_contacts_reported = 1
	body_entered.connect(_on_body_entered)

# -------------------------
# 마우스 입력 & 발사 로직
# -------------------------
func _input(event):
	if not active or is_exploding or not can_drag:
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				is_dragging = true
				drag_start = event.position
				arrow.visible = true
				update_arrow(event.position)
			else:
				if is_dragging:
					is_dragging = false
					arrow.visible = false
					_fire(event.position)
	elif event is InputEventMouseMotion and is_dragging:
		update_arrow(event.position)

func update_arrow(mouse_pos: Vector2):
	# 1) 화살표의 위치 고정
	arrow.global_position = anchor.global_position

	# 2) 방향 벡터 = (마우스 - 탄)	
	var dir = mouse_pos - anchor.global_position
	arrow.rotation = dir.angle() + PI # ← 화살표의 방향

func _fire(release_pos: Vector2):
	start_pos = char_owner.global_position+ Vector2(50, 10)
	freeze = false
	gravity_scale = 1
	sprite.visible = true
	arrow.visible = false
	
	collision_shape.disabled = true
	await get_tree().create_timer(0.1).timeout
	collision_shape.disabled = false
	
	var drag_vector = release_pos - drag_start
	var launch_vector = -drag_vector * power
	linear_velocity = launch_vector

# 물리 및 충돌 처리
func _physics_process(delta: float):
	if freeze:
		if char_owner:
			global_position = char_owner.global_position + Vector2(50, -10)
		return
	if is_exploding:
		return
	linear_velocity.y += gravity * delta
	if linear_velocity.length() > 0.1:
		rotation = linear_velocity.angle()

func _on_body_entered(body: Node):
	if is_exploding:
		return
	if body.name == "Ground":
		print(body.name)
		explode()

	if body.name == "char_red" or "char_silver":
		explode()
		
	if body.name == "Target":
		Target.add_score(1)
		explode()
# -------------------------
# 폭발 및 턴 전환 처리
# 폭발 처리 함수
func explode():
	if is_exploding:
		return
	is_exploding = true
	can_drag = false
	
	var collision_pos = global_position #충돌 지점 저장
	arrow.visible = false
	sprite.visible = false
	
	var explosion = AnimatedSprite2D.new()
	explosion.sprite_frames = animated_sprite.sprite_frames
	explosion.animation = "explode"
	
	#폭발지점 주변 타일 삭제
	destroy_tiles_around_explosion()
	
	explosion.global_position = collision_pos
	explosion.play()
	get_tree().current_scene.add_child(explosion) 


	# 폭발 애니메이션 끝까지 기다린 후
	await explosion.animation_finished
	await get_tree().create_timer(0.5).timeout

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
	animated_sprite.visible = false#애니메이션 이미지 안 보이도록 함
	arrow.visible = false#화살표 이미지 안 보이도록 함

func _stop_physics():
	freeze = true
	linear_velocity = Vector2.ZERO
	angular_velocity = 0
	gravity_scale = 0
