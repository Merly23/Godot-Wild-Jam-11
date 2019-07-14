extends Control

var state = false;

func _process(delta):
	var focus = $"Level/Player".get_global_transform().origin;
	var screen = $"ScreenBuffer".rect_size;
	$"Level/Camera".reposition(screen, focus);
	
	if Input.is_action_just_pressed("ui_down") and $"Stamina".get_amount() > 0 and $"Level/Player".transform(state):
		$"Stamina".decrement()
		$"ScreenBuffer".warp(focus / screen.x);
		
		state = !state;
		for node in get_tree().get_nodes_in_group("Multiskin"):
			node.enter_state(state);
		
		AudioServer.set_bus_mute(1, state);
		AudioServer.set_bus_mute(2, not state);