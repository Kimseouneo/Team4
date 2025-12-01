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
	_start_turn(player1, bullet1)

func _start_turn(player, bullet):
	player.set_active(true)
	bullet.set_active(true)
	print(player.name, "'s TURN START")

#턴 9초로 제한
	if turn_timer:
		turn_timer.queue_free()
	turn_timer = Timer.new()
	turn_timer.wait_time = 9.0
	turn_timer.one_shot = true
	add_child(turn_timer)
	turn_timer.start()
	turn_timer.timeout.connect(next_turn)
	
func next_turn():
	if state == State.PLAYER1_TURN:
		player1.set_active(false)
		bullet1.set_active(false)
		
		player2.set_active(true)
		bullet2.set_active(true)
		state = State.PLAYER2_TURN
		print("Turn → Player 2")
	
	else:
		player2.set_active(false)
		bullet2.set_active(false)
		
		player1.set_active(true)
		bullet1.set_active(true)
		state = State.PLAYER1_TURN
		print("Turn → Player 1")
