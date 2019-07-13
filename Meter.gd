extends AnimatedSprite


func _on_meter_animation_finished():
	animation = String(int(animation) - 1);
	playing = false;