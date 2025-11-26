extends Node2D
@onready var player1 = $"../char_silver"
@onready var player2 = $"../char_red"

var current_turn= 1

func _ready() -> void:
	player1.set_active(true)
	player2.set_active(false)

func next_turn():
	current_turn = (current_turn % 2) + 1
	if current_turn == 1:
		player1.set_active(true)
		player2.set_active(false)
	else:
		player1.set_active(false)
		player2.set_active(true)
