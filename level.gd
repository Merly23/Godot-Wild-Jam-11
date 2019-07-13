extends Control

var state = false;
onready var buf = $"ScreenBuffer";

func _process(delta):
	var focus = $"Level/Player".get_global_transform().origin;
	if Input.is_action_just_pressed("ui_down") and $"Stamina".animation != "0" and $"Level/Player".transform(state):
		var tex = ImageTexture.new();
		var data = get_viewport().get_texture().get_data();
		data.flip_y();
		tex.create_from_image(data);
		buf.texture = tex;
		$Transform.stop();
		$Transform.play("default");
		
		buf.center = focus / buf.rect_size.x;
		
		state = !state;
		for node in get_tree().get_nodes_in_group("Multiskin"):
			if node is Multiskin:
				node.enter_state(state);
		
		$Stamina.playing = true;
	
	focus.y -= 50;
	focus = extents_past_rectangle(focus.x, focus.y, 200, 120, buf.rect_size.x - 200, buf.rect_size.y - 120);
	$"Level".position -= focus * 0.3;
	
	$"Level".position.x = clamp($"Level".position.x, $"Level/Camera".limit_left, $"Level/Camera".limit_right - buf.rect_size.x);
	$"Level".position.y = clamp($"Level".position.y, $"Level/Camera".limit_top, $"Level/Camera".limit_bottom - buf.rect_size.y);


func extents_past_rectangle(x, y, left, top, right, bottom) -> Vector2:
	var v = Vector2.ZERO;
	if x < left: v.x -= left-x;
	elif x > right: v.x = x-right;
	if y < top: v.y -= top-y;
	elif y > bottom: v.y = y-bottom;
	return v