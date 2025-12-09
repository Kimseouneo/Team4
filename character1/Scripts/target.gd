extends StaticBody2D

@onready var score_text: Panel = $"../Score"
@onready var score_label: Label = $"../Score/ScoreLabel"
@onready var bullet = $"../char_silver/bullet"
var score = 0

func _on_bullet_body_entered(body: Node) -> void:
	if body.name == "Target":
		add_score(1)
		show_message("Score: " + str(score))

func add_score(points: int):
	score += points

func show_message(text: String) -> void:
	score_label.text = text 
