extends AnimatedSprite


func _on_meter_animation_finished():
	if animation != "0":
		animation = String(int(animation) - 1);
	playing = false;

func decrement():
	playing = true;
	return int(animation) > 1;

func get_amount():
	return int(animation);