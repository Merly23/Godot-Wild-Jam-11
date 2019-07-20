extends AudioStreamPlayer2D

var time = 0;
func _process(delta):
	if time > 0.4: return;
	time += delta
	if time > 0.4: play();