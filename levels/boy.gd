extends AnimatedSprite

func _ready():
	if $"../..".my_game_data.books[4]:
		queue_free();

func enter_state(state):
	visible = not state;
	if visible and $"../..".my_game_data.books[4]:
		play("fade");

func _on_boy_animation_finished():
	if animation == "fade":
		queue_free();