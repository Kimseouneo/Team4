extends StaticBody2D

@onready var score_text: TextEdit = $"../Score"
@onready var bullet = $"../char_silver/bullet"
var score = 0

func _on_bullet_body_entered(body: Node) -> void:
	if body.name == "Target":
		add_score(1)

func add_score(points: int):
	score += points
	if score_text:
		score_text.text = "Score: " + str(score)
