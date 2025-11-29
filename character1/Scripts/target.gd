extends StaticBody2D

@export	var health = 10


func _on_bullet_body_entered(body: Node) -> void:
	health -= 2
	
