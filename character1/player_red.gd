extends CharacterBody2D
@onready var body_sprite: Sprite2D = $Body
@onready var health_bar: ProgressBar = $HealthBar

@export var health = 10			#현재 체력
@export var max_health = 10		#최대 체력
@export var speed = 250
@export var gravity = 1200.0
@export var jump = 600.0
@export var normal_texture: Texture2D
@export var mid_damage_texture: Texture2D
@export var heavy_damage_texture: Texture2D

var active = false

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
	if not is_on_floor():
		velocity.y += gravity*delta
	else: velocity.y = 0
	
	var direction = Input.get_axis("char_2_left", "char_2_right")
	velocity.x = direction * speed
	
	if Input.is_action_just_pressed("char_2_up") and is_on_floor():
		velocity.y = -jump
	move_and_slide()
	
	if Input.is_action_just_pressed("ui_accept"):
		get_parent().get_node("TurnManager").next_turn()

func _on_bullet_body_entered(body: Node) -> void:
	health -= 1
	_update_health_bar()
