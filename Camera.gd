extends Camera2D

onready var level = get_parent();
var force = false;
var forcus;

func reposition(screen, focus):
	
	focus.y -= 20;
	focus.x += -50 if $"../Player".sprite.flip_h else 50
	if force:
		focus = forcus.get_global_position();
	
	focus = extents_past_rectangle(focus.x, focus.y, screen.x * 2/5, screen.y * 2/5, screen.x * 3/5, screen.y * 3/5);
	level.position -= focus * 0.3;
	
	if not force:
		level.position.x = clamp(level.position.x, -limit_right + screen.x, -limit_left);
	level.position.y = clamp(level.position.y, -limit_bottom + screen.y, -limit_top);
	
	$"../Background".position = level.position * -0.2;


func extents_past_rectangle(x, y, left, top, right, bottom) -> Vector2:
	var v = Vector2.ZERO;
	if x < left: v.x -= left-x;
	elif x > right: v.x = x-right;
	if y < top: v.y -= top-y;
	elif y > bottom: v.y = y-bottom;
	return v

func _on_Reveal_area_entered(area):
	force = true;
	forcus = area;