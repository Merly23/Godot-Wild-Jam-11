extends Control

var state = false;

func _process(delta):
	var focus = $"Level/Player".get_global_transform().origin;
	var screen = Vector2(455, 256);#$"ScreenBuffer".rect_size;
	$"Level/Camera".reposition(screen, focus);
	
	if Input.is_action_just_pressed("ui_down") and $"Stamina".get_amount() > 0 and $"Level/Player".transform(state, false):
		#$"Stamina".decrement()
		$"ScreenBuffer".warp(focus / screen.x);
		
		state = !state;
		for node in get_tree().get_nodes_in_group("Multiskin"):
			node.enter_state(state);
		
		if state:
			$AltTo.play();
			$"Level/Music/tween".play("dark")
		else:
			$AltFrom.play();
			$"Level/Music/tween".play("light")
		
		get_tree().paused = true;

var levels = [preload("res://levels/cave.tscn"), preload("res://levels/cliffs.tscn"), ];
var current = 1;

func _ready():
	add_child_below_node($Background, levels[current].instance());
	swap_level();

func level_transition(pointer):
	if $wipe/AnimationPlayer.is_playing(): return
	var val = 1 if pointer else -1;
	current += val;
	$wipe/AnimationPlayer.play("default");
	$wipe.scale.x = val

func swap_level():
	get_tree().paused = true;
	
	if state:
		for node in get_tree().get_nodes_in_group("Multiskin"):
			node.enter_state(false);
	
	remove_child($Level);
	add_child_below_node($Background, levels[current].instance());
	if state:
		$Level/Player.transform(false, true);
		$Level/Player.sprite.play("idle");
		$Level/Player.state = $Level/Player.form.HUMAN;
		for node in get_tree().get_nodes_in_group("Multiskin"):
			node.enter_state(true);
		$"Level/Music/tween".play("dark", -1, 100)
	else:
		$Level/Player.transform(true, true);
		$Level/Player.sprite.play("fox_idle");
		$Level/Player.state = $Level/Player.form.FOX;
		$"Level/Music/tween".play("light", -1, 100)
	
	if $wipe.scale.x == -1:
		$Level/Player.position = $Level/right_entry.position;
		$Level/Player.vel.x = -10
	$Level/Player.checkpoint = $Level/Player.position;
	get_tree().paused = false;