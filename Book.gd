extends Area2D

export var num = 0;

func _on_Book_body_entered(body):
	if body is Player:
		$AnimatedSprite.play("collect");
		$pickup.play();
		
		body.collect_book(num);

func enter_state(state):
	$AnimatedSprite.material.set_shader_param("enabled", state);

func _on_AnimatedSprite_animation_finished():
	if $AnimatedSprite.animation == "collect":
		visible = false;
		queue_free();
