extends Camera2D

onready var level = get_parent();

func reposition(screen, focus):
	focus.y -= 50;
	focus = extents_past_rectangle(focus.x, focus.y, screen.x * 2/5, screen.y * 2/5, screen.x * 3/5, screen.y * 3/5);
	level.position -= focus * 0.3;
	
	level.position.x = clamp(level.position.x, limit_left, limit_right - screen.x);
	level.position.y = clamp(level.position.y, limit_top, limit_bottom - screen.y);


func extents_past_rectangle(x, y, left, top, right, bottom) -> Vector2:
	var v = Vector2.ZERO;
	if x < left: v.x -= left-x;
	elif x > right: v.x = x-right;
	if y < top: v.y -= top-y;
	elif y > bottom: v.y = y-bottom;
	return v