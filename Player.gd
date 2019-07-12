extends KinematicBody2D

const GRAVITY = 1000;
const FRICTION = 0.1;
const FRICTION_AIR = 0.02;
const RUN_FORCE = 1000;
const FLY_FORCE = 300;
const JUMP_FORCE = 30000;
const RISE_FORCE = 50;

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
	else:
		sprite.flip_h = true;
		sprite.offset.x = -abs(sprite.offset.x);
	if sprite.animation == "idle":
		if movement.x != 0 and abs(vel.x) > 1:
			sprite.play("run_start");
	elif sprite.animation == "xform" or sprite.animation == "fox_xform":
		return
	elif sprite.animation == "fox_idle":
		return
	else:
		if movement == Vector2.ZERO and abs(vel.x) < 30:
			sprite.play("idle");

func _on_AnimatedSprite_animation_finished():
	if sprite.animation == "run_start":
		sprite.play("run");
	if sprite.animation == "xform":
		state = form.FOX;
		sprite.play("fox_idle");
	if sprite.animation == "fox_xform":
		state = form.HUMAN;
		sprite.play("idle");

func transform(to_human):
	if sprite.animation == "idle" and not to_human:
		sprite.play("xform");
		state = form.XFORM;
		return true
	elif sprite.animation == "fox_idle" and to_human:
		sprite.play("fox_xform");
		state = form.XFORM;
		return true
	return false