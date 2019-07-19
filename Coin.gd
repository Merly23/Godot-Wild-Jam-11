extends Area2D


func _on_Coin_body_entered(body):
	if body is Player and visible:
		$AnimatedSprite.play("collect");
		$pickup.play();

func enter_state(state):
	$AnimatedSprite.material.set_shader_param("enabled", state);

func _on_AnimatedSprite_animation_finished():
	if $AnimatedSprite.animation == "collect":
		visible = false;


func _on_pickup_finished():
	queue_free();
