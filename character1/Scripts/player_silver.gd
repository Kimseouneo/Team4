extends CharacterBody2D
@onready var body_sprite: Sprite2D = $Body
@onready var health_bar: ProgressBar = $HealthBar

@export var health = 10			#현재 체력
@export var max_health = 10		#최대 체력
@export var speed = 250
@export var gravity = 1200.0
@export var jump = 600.0
@export var max_jump_time = 0.25
@export var jump_hold_force = 400.0
@export var normal_texture: Texture2D
@export var mid_damage_texture: Texture2D
@export var heavy_damage_texture: Texture2D

var active = false
var jump_time = 0.0
var jumping = false
#활성화 비활성화
func set_active(state: bool):
	active = state

func _ready():
	# 초기 텍스처 세팅
	body_sprite.texture = normal_texture
	health_bar.max_value = max_health
	health_bar.value = health
	
func take_damage(amount: int):
	health = max(health - amount, 0)
	_update_body_texture()
	_update_health_bar()

func _update_health_bar(): #피해의 정도에 따라 체력바 업데이트
	if health_bar:
		health_bar.value = health

func _update_body_texture(): #피해의 정도에 따라 캐릭터의 texture를 업데이트
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
		jumping = false
		jump_time = 0.0
	# 점프 처리 — move_and_slide() 전에 해야 함
	if Input.is_action_just_pressed("char_1_up") and is_on_floor():
		jumping = true
		jump_time = 0.0
		velocity.y = -jump
	if Input.is_action_pressed("char_1_up") and jumping:
		jump_time += delta
		if jump_time < max_jump_time:
			velocity.y -= jump_hold_force * delta
		else:
			jumping = false
	# 좌우 이동
	var direction = Input.get_axis("char_1_left", "char_1_right")
	velocity.x = direction * speed

	# 실제 이동은 제일 마지막에
	move_and_slide()


func _on_bullet_red_body_entered(body: Node) -> void:
	if body.name == "char_silver":
		take_damage(1)
		_update_health_bar()
