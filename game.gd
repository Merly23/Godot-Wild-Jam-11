extends Control

var state = true;

func _process(delta):
	if get_node_or_null("Level/Player") == null: return
	
	if Input.is_action_just_pressed("ui_cancel"):
		if not get_tree().paused:
			get_tree().paused = true;
			$pause.visible = true;
			$pause.workaround = true;
			$pause.select = 0;
	
	var focus = $"Level/Player".get_global_transform().origin;
	var screen = Vector2(455, 256);#$"ScreenBuffer".rect_size;
	$"Level/Camera".reposition(screen, focus);
	
	if Input.is_action_just_pressed("player_transform") and $"Level/Player".transform(state, false):
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

var levels = [preload("res://levels/cave.tscn"), preload("res://levels/cliffs.tscn"), preload("res://levels/shrine.tscn")];

var my_game_data := {
	"level": -1,
	"from_right": false,
	"books": [false, false, false, false, false]
	}

func save() -> void:
	assert(my_game_data.level != -1);
	var save_game := SaveGame.new()
	save_game.data = my_game_data
	ResourceSaver.save("user://save_game.tres", save_game)

func ld() -> void:
	var save_game = load("user://save_game.tres")
	
	if not save_game:
	    print("no save file")
	else:
		my_game_data = save_game.data
		update_orbs();

func _ready():
	ld();

func update_orbs():
	$orbs/orb1.visible = my_game_data.books[0];
	$orbs/orb2.visible = my_game_data.books[1];
	$orbs/orb3.visible = my_game_data.books[2];
	$orbs/orb4.visible = my_game_data.books[3];
	$orbs/orb5.visible = my_game_data.books[4];
	$story.count = 0;
	for i in my_game_data.books:
		if i: $story.count += 1;

func level_transition(val):
	if $wipe/AnimationPlayer.is_playing(): return false
	my_game_data.level += val;
	$wipe/AnimationPlayer.play("default");
	if val != 0:
		$wipe.scale.x = val
		my_game_data.from_right = val == -1
	return true

func swap_level():
	get_tree().paused = true;
	
	if state:
		for node in get_tree().get_nodes_in_group("Multiskin"):
			node.enter_state(false);
	
	remove_child($Level);
	add_child_below_node($"Background-high", levels[my_game_data.level].instance());
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
	
	if my_game_data.from_right:
		$Level/Player.position = $Level/right_entry.position;
		$Level/Player.vel.x = -10
	$Level/Player.checkpoint = $Level/Player.position;
	
	for node in get_tree().get_nodes_in_group("Book"):
		if my_game_data.books[node.num]:
			node.get_parent().remove_child(node);
	$"Background-high".visible = my_game_data.level == 2;
	
	save();
	$Health.play("4");
	$Health.playing = false;
	get_tree().paused = false;