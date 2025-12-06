extends Node2D
#player1의 객체
@onready var player1 = $"../char_silver"
@onready var bullet1 = $"../char_silver/bullet_silver"
#player2의 객체
@onready var player2 = $"../char_red"
@onready var bullet2 = $"../char_red/bullet_red"

enum State { PLAYER1_TURN, PLAYER2_TURN }
var state = State.PLAYER1_TURN
var turn_timer = null
func _ready():
	#오류 방지를 위한 초기화
	_end_turn(player1, bullet1)
	_end_turn(player2, bullet2)
	# 타이머 한 번만 생성 & 껐다가 키는 방식
	turn_timer = Timer.new()
	turn_timer.wait_time = 5.0   # 5초
	turn_timer.one_shot = false  # 반복
	add_child(turn_timer)
	turn_timer.timeout.connect(next_turn)
	turn_timer.start()

	# 첫 턴 시작
	state = State.PLAYER1_TURN	
	_start_turn(player1, bullet1)

func _start_turn(player, bullet):
	player.set_active(true)
	bullet.set_active(true)
	print(player.name, "'s TURN START")

func _end_turn(player, bullet):
	player.set_active(false)
	bullet.set_active(false)
	if player == player1:
		bullet1.global_position = player1.get_node("Anchor").global_position + Vector2(50, -10)
	if player == player2:
		bullet2.global_position = player2.get_node("Anchor").global_position + Vector2(-50, -10)
	
func next_turn():
	if state == State.PLAYER1_TURN:
		_start_turn(player2, bullet2)
		_end_turn(player1, bullet1)
		state = State.PLAYER2_TURN
		print("Turn → Player 2")
	
	else:
		_start_turn(player1, bullet1)
		_end_turn(player2, bullet2)	
		state = State.PLAYER1_TURN
		print("Turn → Player 1")
