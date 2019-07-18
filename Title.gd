extends Node2D

var select = 0;

func _process(delta):
	
	if Input.is_action_just_pressed("ui_end"):
		$"..".level_transition(1);
	
	if Input.is_action_just_pressed("ui_up"):
		select -= 1;
	elif Input.is_action_just_pressed("ui_down"):
		select += 1;
	select = fposmod(select, 3);
	
	$arrow.position.y = 200 + 20 * select;
	
	if Input.is_action_just_pressed("ui_accept"):
		match select:
			0.0:
				$text.visible = false
				$textshadow.visible = false
				$arrow.visible = false
				$AnimationPlayer.play("default")
			1.0:
				pass
			2.0:
				get_tree().quit();

func _on_AnimationPlayer_animation_finished(anim_name):
	$"..".level_transition(1);
