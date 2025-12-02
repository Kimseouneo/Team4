extends CharacterBody2D

@onready var body_sprite: Sprite2D = $Body
@onready var health_bar: ProgressBar = $HealthBar

@export var health: int = 10
@export var max_health: int = 10
@export var speed: float = 250.0
@export var gravity: float = 1200.0
@export var jump_force: float = 600.0
@export var max_jump_time: float = 0.25
@export var jump_hold_force: float = 400.0

@export var normal_texture: Texture2D
@export var mid_damage_texture: Texture2D
@export var heavy_damage_texture: Texture2D

var active := false
var is_jumping := false
var jump_time := 0.0

func set_active(state: bool) -> void:
	active = state

func _ready() -> void:
	body_sprite.texture = normal_texture
	health_bar.max_value = max_health
	health_bar.value = health

func take_damage(amount: int) -> void:
	health = max(health - amount, 0)
	_update_body_texture()
	_update_health_bar()

func _update_health_bar() -> void:
	if health_bar:
		health_bar.value = health

func _update_body_texture() -> void:
	if health > 6:
		body_sprite.texture = normal_texture
	elif health > 3:
		body_sprite.texture = mid_damage_texture
	else:
		body_sprite.texture = heavy_damage_texture

func _physics_process(delta: float) -> void:
	if not active:
		return

	# 중력 적용
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		is_jumping = false
		jump_time = 0.0

	# 가변 점프
	if Input.is_action_just_pressed("char_2_up") and is_on_floor():
		is_jumping = true
		jump_time = 0.0
		velocity.y = -jump_force
	elif Input.is_action_pressed("char_2_up") and is_jumping:
		jump_time += delta
		if jump_time < max_jump_time:
			velocity.y -= jump_hold_force * delta
		else:
			is_jumping = false

	# 좌우 이동
	var direction = Input.get_axis("char_2_left", "char_2_right")
	velocity.x = direction * speed

	move_and_slide()

	# 턴 수동 전환
	if Input.is_action_just_pressed("ui_accept")and active:
		get_parent().get_node("Turnmanager").next_turn()

func _on_bullet_silver_body_entered(body: Node) -> void:
	take_damage(1)
	_update_health_bar()
