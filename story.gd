extends Node2D

var select = 0;
var count = 0;

func _process(delta):
	if not visible: return;
	
	if Input.is_action_just_pressed("ui_left"):
		select -= 1;
		select = clamp(select, 0, 2);
		refresh();
	if Input.is_action_just_pressed("ui_right"):
		select += 1;
		select = clamp(select, 0, 2);
		refresh();
	if Input.is_action_just_pressed("ui_cancel"):
		visible = false;
		get_tree().paused = false;

var pages = [
	[
		preload("res://sprites/story/1_0.png"),
		preload("res://sprites/story/1_1.png"),
		preload("res://sprites/story/1_2.png"),
		preload("res://sprites/story/1_3.png"),
		preload("res://sprites/story/1_3.png"),
		preload("res://sprites/story/1_3.png"),
	],[
		preload("res://sprites/story/2_2.png"),
		preload("res://sprites/story/2_2.png"),
		preload("res://sprites/story/2_2.png"),
		preload("res://sprites/story/2_3.png"),
		preload("res://sprites/story/2_4.png"),
		preload("res://sprites/story/2_5.png"),
	],[
		preload("res://sprites/story/3_1.png"),
		preload("res://sprites/story/3_2.png"),
		preload("res://sprites/story/3_2.png"),
		preload("res://sprites/story/3_3.png"),
		preload("res://sprites/story/3_4.png"),
		preload("res://sprites/story/3_5.png"),
	]];

func refresh():
	$Sprite.texture = pages[select][count];
	$turn.play();