extends RigidBody2D

@export var gravity: float = 500.0
@export var power: float = 5.0
@export var arrow_scale_damp: float = 50.0

var is_dragging := false
var drag_start := Vector2.ZERO
var is_exploding := false
var initial_arrow_scale: Vector2

@onready var sprite: Sprite2D = $Bullet
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var arrow_sprite: Sprite2D = $Arrow
@onready var collision_shape = $CollisionShape2D
@onready var char_owner: Node2D = get_parent()
@onready var turn_manager: Node = $"../../Turnmanager"

var active: bool = false

func set_active(state: bool):
	active = state

func _ready():
	freeze = true
	gravity_scale = 0
	sprite.visible = false
	animated_sprite.visible = false
	arrow_sprite.visible = false
	initial_arrow_scale = arrow_sprite.scale
	contact_monitor = true
	max_contacts_reported = 1
	body_entered.connect(_on_body_entered)

# -------------------------
# 마우스 입력 & 발사 로직
# -------------------------
func _input(event):
	if not active or is_exploding:
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				is_dragging = true
				drag_start = event.position
				arrow_sprite.visible = true
				update_arrow(event.position)
			else:
				if is_dragging:
					is_dragging = false
					arrow_sprite.visible = false
					_fire(event.position)
	elif event is InputEventMouseMotion and is_dragging:
		update_arrow(event.position)

func update_arrow(current_mouse_pos: Vector2):
	var aim_vector = drag_start - current_mouse_pos
	arrow_sprite.rotation = aim_vector.angle()
	var drag_distance = aim_vector.length()
	var stretch_ratio = clamp(drag_distance / arrow_scale_damp, 1.0, 3.0)
	arrow_sprite.scale = Vector2(initial_arrow_scale.x * stretch_ratio, initial_arrow_scale.y)

func _fire(release_pos: Vector2):
	freeze = false
	gravity_scale = 1
	sprite.visible = true
	var drag_vector = release_pos - drag_start
	var launch_vector = -drag_vector * power
	linear_velocity = launch_vector

	# 발사 직후 0.2초 동안 자기 자신과의 충돌 방지
	collision_shape.disabled = true
	await get_tree().create_timer(0.2).timeout
	collision_shape.disabled = false

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
	if body == char_owner:
		return # 자기 자신과 충돌 방지
	explode()

# -------------------------
# 폭발 및 턴 전환 처리
# -------------------------
func explode():
	if is_exploding:
		return
	is_exploding = true

	arrow_sprite.visible = false

	sprite.visible = false
	animated_sprite.visible = true
	animated_sprite.play("explode")

	# 🔹 폭발 애니메이션 끝까지 기다린 후
	await animated_sprite.animation_finished
	await get_tree().create_timer(0.5).timeout

	stop_bullet()

	# 🔹 턴 전환
	if turn_manager and active:
		print(">>> Bullet exploded! Passing turn...")
		turn_manager.next_turn()
	active = false  # 비활성화

func stop_bullet():
	is_exploding = false
	freeze = true
	gravity_scale = 0
	linear_velocity = Vector2.ZERO
	rotation = 0
	sprite.visible = false
	animated_sprite.visible = false
	arrow_sprite.visible = false
	if char_owner:
		global_position = char_owner.global_position + Vector2(50, -10)

func _stop_physics():
	freeze = true
	linear_velocity = Vector2.ZERO
	angular_velocity = 0
	gravity_scale = 0
