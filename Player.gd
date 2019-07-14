extends KinematicBody2D
class_name Player

var GRAVITY = 1000;
var FRICTION = 0.1;
var FRICTION_AIR = 0.02;
var RUN_FORCE = 1000;
var FLY_FORCE = 300;
var JUMP_FORCE = 15000;
var RISE_FORCE = 2000;

var vel = Vector2.ZERO;
var air_time = 0;
var iframes = -1;

enum form {HUMAN, FOX, XFORM};
var state = form.HUMAN;

var checkpoint : Vector2;

func _ready():
	transform(true, true);
	sprite.play("fox_idle");
	state = form.FOX;
	checkpoint = position;

var movement = Vector2.ZERO;

func _physics_process(delta):
	
	if state == form.XFORM: return;
	var accel = Vector2.ZERO;
	
	movement = Vector2.ZERO;
	movement.x += 1 if Input.is_action_pressed("ui_right") else 0;
	movement.x += -1 if Input.is_action_pressed("ui_left") else 0;
	movement *= RUN_FORCE if is_on_floor() else FLY_FORCE;
	
	if is_on_floor() and Input.is_action_just_pressed("ui_accept"):
		movement.y -= JUMP_FORCE;
		air_time = 0;
		accel += get_floor_velocity();
	elif Input.is_action_pressed("ui_accept"):
		air_time += delta;
		movement.y -= RISE_FORCE * pow(0.5, air_time * 7);
	
	
	accel += movement * delta;
	if is_on_floor():
		if vel.length() < 30 and movement.x == 0:
			accel -= vel
		else:
			accel -= vel * FRICTION
	else:
		accel -= vel * FRICTION_AIR
	accel.y += GRAVITY * delta;
	
	vel += accel;
	vel = move_and_slide(vel + get_floor_velocity() * delta, Vector2(0, -1), true);
	
	
	if position.y > $"../Camera".limit_bottom + 50:
		position = checkpoint;
		vel = Vector2.ZERO;
		hurt();

onready var sprite = get_node("AnimatedSprite");

func _process(delta):
	if sprite.animation != "stunned":
		if vel.x > 0:
			sprite.flip_h = false;
			sprite.offset.x = abs(sprite.offset.x);
		elif vel.x < 0:
			sprite.flip_h = true;
			sprite.offset.x = -abs(sprite.offset.x);
	
	if iframes >= 0: iframes += delta;
	if iframes > 1:
		sprite.play("hitflash" if state == form.HUMAN else "fox_hitflash");
		iblink(false);
		iframes = -1;
	
	var VERT_THRESHOLD = 250;
	var HORIZ_THRESHOLD = 30;
	match sprite.animation:
		"idle":
			if movement.y != 0:
				sprite.animation = "jump";
			elif movement.x != 0:
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
		"stunned":
			if is_on_floor():
				sprite.animation = "land";
		"run":
			if abs(vel.x) < HORIZ_THRESHOLD and abs(vel.y) < 1:
				sprite.play("idle");
			elif vel.y < -VERT_THRESHOLD and not is_on_floor():
				sprite.play("jump");
			elif vel.y > VERT_THRESHOLD:
				sprite.play("fall");
		"run_start":
			if abs(vel.x) < HORIZ_THRESHOLD and abs(vel.y) < 1:
				sprite.play("idle");
			elif vel.y < -VERT_THRESHOLD and not is_on_floor():
				sprite.play("jump");
			elif vel.y > VERT_THRESHOLD:
				sprite.play("fall");
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

func _on_AnimatedSprite_animation_finished():
	match sprite.animation:
		"run_start":
			sprite.play("run");
		"jump":
			sprite.play("rise");
		"fall_start":
			sprite.play("fall");
		"land":
			sprite.play("idle");
		"fox_run_end":
			sprite.play("fox_idle");
		
		"hitflash":
			sprite.play("stunned");
			iblink(true);
		"fox_hitflash":
			sprite.play("fox_idle");
			iblink(true);
		
		"xform":
			state = form.FOX;
			sprite.play("fox_idle");
			sprite.offset.x *= 2;
		"fox_xform":
			state = form.HUMAN;
			sprite.play("idle");

func transform(switch, force):
	if iframes >= 0: return
	if (sprite.animation == "idle" or force) and switch:
		sprite.play("xform");
		state = form.XFORM;
		GRAVITY = 800;
		FRICTION = 0.1;
		FRICTION_AIR = 0.02;
		RUN_FORCE = 1700;
		FLY_FORCE = 600;
		JUMP_FORCE = 20000;
		RISE_FORCE = 100;
		$Human.disabled = true;
		$Fox.disabled = false;
		collision_layer = 1;
		collision_mask = 1;
		return true
	elif (sprite.animation == "fox_idle" or force) and not switch:
		sprite.play("fox_xform");
		state = form.XFORM;
		GRAVITY = 1000;
		FRICTION = 0.1;
		FRICTION_AIR = 0.02;
		RUN_FORCE = 1000;
		FLY_FORCE = 300;
		JUMP_FORCE = 15000;
		RISE_FORCE = 2000;
		$Fox.disabled = true;
		$Human.disabled = false;
		collision_layer = 2;
		collision_mask = 2;
		
		sprite.offset.x /= 2;
		return true
	return false

func hurt():
	if iframes > 0: return
	$"../../Health".decrement();
	if state == form.FOX:
		sprite.play("fox_hitflash");
	else:
		sprite.play("hitflash");
	
	iframes = 0;

func knock(direction):
	if iframes > 0: return
	direction.y -= 1;
	direction *= 300;
	vel += direction;

func iblink(on):
	if iframes >= 0:
		sprite.material.set_shader_param("enabled", on)
