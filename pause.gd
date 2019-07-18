extends Node2D

var workaround = false;
var select = 0;

func _process(delta):
	if not visible: return
	
	if Input.is_action_just_pressed("ui_cancel") and not workaround:
		visible = false;
		get_tree().paused = false;
	workaround = false;
	
	if Input.is_action_just_pressed("ui_up"):
		select -= 1;
	elif Input.is_action_just_pressed("ui_down"):
		select += 1;
	select = fposmod(select, 3);
	
	$arrow.position.y = 108 + 20 * select;
	
	if Input.is_action_just_pressed("ui_accept"):
		match select:
			0.0:
				visible = false;
				get_tree().paused = false;
			1.0:
				pass
			2.0:
				get_tree().quit();