extends Node2D

@onready var player1 = $"../char_silver"
@onready var player2 = $"../char_red"

enum State { PLAYER1_TURN, PLAYER2_TURN }
var state = State.PLAYER1_TURN

func _ready():
	_start_turn(player1)

func _start_turn(player):
	player.set_active(true)
	print(player.name, "TURN START")

func next_turn():
	if state == State.PLAYER1_TURN:
		player1.set_active(false)
		player2.set_active(true)
		state = State.PLAYER2_TURN
		print("Turn → Player 2")
	else:
		player1.set_active(true)
		player2.set_active(false)
		state = State.PLAYER1_TURN
		print("Turn → Player 1")
