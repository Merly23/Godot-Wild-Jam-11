extends KinematicBody2D

var GRAVITY = 1000;
var FRICTION = 0.1;
var FRICTION_AIR = 0.02;
var RUN_FORCE = 1000;
var FLY_FORCE = 300;
var JUMP_FORCE = 30000;
var RISE_FORCE = 50;

var vel = Vector2.ZERO;

enum form {HUMAN, FOX, XFORM};
var state = form.HUMAN;

func _ready():
	pass

var movement = Vector2.ZERO;

func _physics_process(delta):
	
	if state == form.XFORM: return;
	
	movement = Vector2.ZERO;
	movement.x += 1 if Input.is_action_pressed("ui_right") else 0;
	movement.x += -1 if Input.is_action_pressed("ui_left") else 0;
	movement *= RUN_FORCE if is_on_floor() else FLY_FORCE;
	
	if is_on_floor() and Input.is_action_just_pressed("ui_accept"):
		movement.y -= JUMP_FORCE;
	if Input.is_action_pressed("ui_accept"):
		movement.y -= RISE_FORCE;
	
	
	var accel = Vector2.ZERO;
	
	accel.y += GRAVITY * delta;
	accel += movement * delta;
	
	accel -= vel * (FRICTION if is_on_floor() else FRICTION_AIR);
	
	vel += accel;
	
	vel = move_and_slide(vel, Vector2(0, -1));
	
	for i in range(1, get_slide_count()):
		pass

onready var sprite = get_node("AnimatedSprite");

func _process(delta):
	if vel.x > 0:
		sprite.flip_h = false;
		sprite.offset.x = abs(sprite.offset.x);
	elif vel.x < 0:
		sprite.flip_h = true;
		sprite.offset.x = -abs(sprite.offset.x);
	
	match sprite.animation:
		"idle":
			if vel.y < 0:
				sprite.animation = "jump";
			elif movement.x != 0 and abs(vel.x) > 1:
				sprite.play("run_start");
		"rise":
			if vel.y > 0:
				sprite.animation = "fall_start";
		"jump":
			if vel.y > 0:
				sprite.animation = "fall_start";
		"fall":
			if is_on_floor():
				sprite.animation = "land";
		"fall_start":
			if is_on_floor():
				sprite.animation = "land";
		"xform":
			return
		"fox_xform":
			return
		"fox_idle":
			if movement.x != 0 and abs(vel.x) > 1:
				sprite.play("fox_run");
		"fox_run":
			if abs(vel.x) < 100:
				sprite.play("fox_run_end");
		"run":
			if abs(vel.x) < 30 and abs(vel.y) < 1:
				sprite.play("idle");
			elif vel.y < 0:
				sprite.play("jump");
			elif vel.y > 0:
				sprite.play("fall");
		"run_start":
			if abs(vel.x) < 30 and abs(vel.y) < 1:
				sprite.play("idle");
			elif vel.y < 0:
				sprite.play("jump");
			elif vel.y > 0:
				sprite.play("fall");

func _on_AnimatedSprite_animation_finished():
	if sprite.animation == "run_start":
		sprite.play("run");
	if sprite.animation == "jump":
		sprite.play("rise");
	if sprite.animation == "fall_start":
		sprite.play("fall");
	if sprite.animation == "land":
		sprite.play("idle");
	if sprite.animation == "fox_run_end":
		sprite.play("fox_idle");
	
	if sprite.animation == "xform":
		state = form.FOX;
		sprite.play("fox_idle");
		sprite.offset.x *= 2;
	if sprite.animation == "fox_xform":
		state = form.HUMAN;
		sprite.play("idle");

func transform(to_human):
	if sprite.animation == "idle" and not to_human:
		sprite.play("xform");
		state = form.XFORM;
		GRAVITY = 800;
		FRICTION = 0.1;
		FRICTION_AIR = 0.02;
		RUN_FORCE = 2000;
		FLY_FORCE = 600;
		JUMP_FORCE = 20000;
		RISE_FORCE = 100;
		return true
	elif sprite.animation == "fox_idle" and to_human:
		sprite.play("fox_xform");
		state = form.XFORM;
		GRAVITY = 1000;
		FRICTION = 0.1;
		FRICTION_AIR = 0.02;
		RUN_FORCE = 1000;
		FLY_FORCE = 300;
		JUMP_FORCE = 30000;
		RISE_FORCE = 50;
		sprite.offset.x /= 2;
		return true
	return false