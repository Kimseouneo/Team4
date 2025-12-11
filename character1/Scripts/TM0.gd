extends Node
#player1의 객체
@onready var player1 = $"../char_silver"
@onready var bullet1 = $"../char_silver/bullet"

enum State { PLAYER1_TURN}
var state = State.PLAYER1_TURN
var turn_timer = null
func _ready():
	_start_turn(player1, bullet1)

func _start_turn(player, bullet):
	player.set_active(true)
	bullet.set_active(true)
	print(player.name, "Game START")
	print(bullet1.global_position)

#턴 5초로 제한
	if turn_timer:
		turn_timer.queue_free()
	turn_timer = Timer.new()
	turn_timer.wait_time = 5.0
	turn_timer.one_shot = true
	add_child(turn_timer)
	turn_timer.start()

func next_turn():
	if state == State.PLAYER1_TURN:
		player1.set_active(true)
		bullet1.set_active(true)
		bullet1.global_position = player1.get_node("Anchor").global_position + Vector2(50, -10)
	print(bullet1.global_position)
