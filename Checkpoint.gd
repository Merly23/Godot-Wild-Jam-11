extends Area2D



func _on_Checkpoint_body_entered(body):
	if body is Player:
		body.checkpoint = position;