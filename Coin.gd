extends Area2D



func _on_Coin_body_entered(body):
	if body is Player:
		visible = false;
		queue_free();