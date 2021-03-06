extends KinematicBody2D
class_name Player

#Fundamental constants for player physics

#They would normally be const and not var, but I
#decided to change some of them when switching between forms

#1000 on a force, despite being a large number is pretty typical
#because we multiply by delta time. So a velocity of 1000 (px/s)
#means you move 1000px in one second. An acceleration of gravity
#of 1000 (px/s^2) means it takes one second to get to that speed
#(but due to air friction you would never quite hit that high of a speed)
var GRAVITY = 1000;
var FRICTION = 0.1;
var FRICTION_WALL = 0.3;
var FRICTION_AIR = 0.02;
var RUN_FORCE = 1000;
var FLY_FORCE = 300;
var JUMP_FORCE = 15000;
var RISE_FORCE = 2000;

#velocity is stored between frames, whereas acceleration
#is calculated fresh every frame based on the forces
#acting upon the player at that moment
var vel = Vector2.ZERO;

#stores which keys we have pressed — gets reset every frame but
#still useful for multiple functions
var movement = Vector2.ZERO;

#time spent in the air is tracked so the longer you hold
#the jump button the less upwards acceleration you get
var air_time = 0;

#when you take damage the player starts flashing and
#this variable counts down from 1.5 to zero;
#-1 means the player shouldn't be flashing
var iframes = -1;

#at some point we say the player is falling fast enough to take damage
#and we need to store it in a variable, because by the time the player
#lands, his vertical velocity will have reset to zero
var terminal_velocity = false;

#depending on the environment we're in we play dirt footstep sounds instead
var dirty = false;

enum form {HUMAN, FOX, XFORM};
var state = form.HUMAN;
var dead = false;

#stores our position to respawn at when falling off a cliff (not dying)
var checkpoint : Vector2;

func _physics_process(delta):
	
	if state == form.XFORM or sprite.animation == "death": return;
	var accel = Vector2.ZERO;
	
	movement = Vector2.ZERO;
	if not dead:
		#movement is like a second acceleration variable
		#used for some special movement purposes
		movement.x += 1 if Input.is_action_pressed("player_right") else 0;
		movement.x += -1 if Input.is_action_pressed("player_left") else 0;
		movement *= RUN_FORCE if is_on_floor() else FLY_FORCE;
		
		if Input.is_action_just_pressed("player_jump"):
			if is_on_floor():
				movement.y -= JUMP_FORCE;
				if state == form.FOX: movement.x *= 3;
				accel += get_floor_velocity();
				air_time = 0;
			elif wallsliding() and wall != 0 and state == form.HUMAN:
				movement.x = -wall * 0.8;
				movement.y = -0.8;
				movement *= JUMP_FORCE;
				air_time = 0;
				vel = Vector2.ZERO;
		elif Input.is_action_pressed("player_jump"):
			#give a little extra "boost" each frame we keep holding the jump button
			#and we won't jump as high if we just tap the jump button
			air_time += delta;
			movement.y -= RISE_FORCE * pow(0.5, air_time * 7);
	
	
	accel += movement * delta;
	if is_on_floor():
		if vel.length() < 30 and movement.x == 0:
			accel -= vel
		else:
			accel -= vel * FRICTION;
	elif wallsliding() and state == form.HUMAN:
		accel -= vel * FRICTION_WALL;
		#if movement.x == 0:
		movement.x = wall * FLY_FORCE * 5
	else:
		accel -= vel * FRICTION_AIR;
	accel.y += GRAVITY * delta;
	
	vel += accel;
	var new_vel = move_and_slide(vel + get_floor_velocity() * delta, Vector2(0, -1), true);
	
	if wallsliding():
		if wall == 0:
			wall = sign(vel.x)
	else:
		wall = 0;
	vel = new_vel
	
	if position.y > $"../Camera".limit_bottom + 50:
		hurt();
		vel = Vector2.ZERO;
		if not dead:
			position = checkpoint;
		else:
			$"../..".level_transition(0);
	
	if state == form.HUMAN:
		if vel.y > 500:
			terminal_velocity = true;
		if terminal_velocity and wallsliding():
			terminal_velocity = false;
		if terminal_velocity and is_on_floor():
			hurt();
			terminal_velocity = false;

var was_on_wall = 0;
var wall = 0;

func wallsliding():
	if was_on_wall == -1: return;
	if is_on_wall(): was_on_wall = 3;
	if is_on_floor(): was_on_wall = 0;
	return was_on_wall > 0 and vel.y > 0;

onready var sprite = get_node("AnimatedSprite");

func _process(delta):
	
	was_on_wall = max(0, was_on_wall - 1);
	if is_on_floor(): was_on_wall = 0;
	
	if sprite.animation != "stunned":
		if vel.x > 0:
			sprite.flip_h = false;
			sprite.offset.x = abs(sprite.offset.x);
		elif vel.x < 0:
			sprite.flip_h = true;
			sprite.offset.x = -abs(sprite.offset.x);
	
	if iframes >= 0: iframes += delta;
	if iframes > 1.5:
		#sprite.play("hitflash" if state == form.HUMAN else "fox_hitflash");
		iblink(false);
		iframes = -1;
	
	var VERT_THRESHOLD = 250;
	var HORIZ_THRESHOLD = 30;
	
	if state == form.HUMAN and sprite.animation != "hitflash":
		if wallsliding() and vel.y > 10:
			sprite.play("wallslide");
			if not $audio/Wallslide.playing:
				$audio/Wallslide.play();
		elif is_on_floor() and dead:
			sprite.play("death");
			$Human.disabled = true;
	
	match sprite.animation:
		"idle":
			if movement.y != 0:
				sprite.play("jump");
				if dirty: $audio/GirlJumpDirt.play();
				else: $audio/GirlJump.play();
			elif movement.x != 0 and abs(vel.x) > 1:
				sprite.play("run_start");
		"rise":
			if vel.y >= 0:
				sprite.play("fall_start");
		"jump":
			if vel.y >= 0:
				sprite.play("fall_start");
		"fall":
			if is_on_floor():
				sprite.play("land");
				if dirty: $audio/GirlStep.play();
				else: $audio/GirlLand.play();
		"fall_start":
			if is_on_floor():
				sprite.play("land");
				if dirty: $audio/GirlStep.play();
				else: $audio/GirlLand.play();
		"stunned":
			if is_on_floor():
				sprite.play("land");
		"wallslide":
			if not wallsliding():
				sprite.play("jump");
				$audio/Wallslide.stop();
				if vel.y < 50:
					if dirty: $audio/GirlJumpDirt.play();
					else: $audio/GirlJump.play();
		"run":
			if abs(vel.x) < HORIZ_THRESHOLD and abs(vel.y) < 1:
				sprite.play("idle");
			elif vel.y < -VERT_THRESHOLD and not is_on_floor():
				sprite.play("jump");
				if dirty: $audio/GirlJumpDirt.play();
				else: $audio/GirlJump.play();
			elif vel.y > VERT_THRESHOLD:
				sprite.play("fall");
		"run_start":
			if abs(vel.x) < HORIZ_THRESHOLD and abs(vel.y) < 1:
				sprite.play("idle");
			elif vel.y < -VERT_THRESHOLD and not is_on_floor():
				sprite.play("jump");
				if dirty: $audio/GirlJumpDirt.play();
				else: $audio/GirlJump.play();
			elif vel.y > VERT_THRESHOLD:
				sprite.play("fall");
		"xform":
			return
		"fox_xform":
			return
		"fox_idle":
			if movement.x != 0 and abs(vel.x) > 1:
				sprite.play("fox_run");
			if movement.y != 0:
				sprite.play("fox_jump");
				if dirty: $audio/FoxJumpDirt.play();
				else: $audio/FoxJump.play();
		"fox_run":
			if abs(vel.x) < 100:
				sprite.play("fox_run_end");
			if movement.y != 0:
				sprite.play("fox_jump");
			elif vel.y > VERT_THRESHOLD / 2:
				sprite.play("fox_fall");
		"fox_jump":
			if vel.y > 0:
				sprite.play("fox_fall");
			if is_on_floor():
				if abs(vel.x) < 100:
					sprite.play("fox_idle");
				else:
					sprite.play("fox_run");
		"fox_fall":
			if is_on_floor():
				if dirty: $audio/FoxStep.play();
				else: $audio/FoxLand.play();
				if abs(vel.x) < 100:
					sprite.play("fox_idle");
				else:
					sprite.play("fox_run");

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
			if iframes >= 0:
				sprite.play("stunned");
				iblink(true);
			elif is_on_floor():
				sprite.play("idle");
			else:
				sprite.play("rise");
		"fox_hitflash":
			sprite.play("fox_idle");
			iblink(true);
		
		"xform":
			state = form.FOX;
			sprite.play("fox_idle");
			get_tree().paused = false;
			#sprite.offset.x *= -3;
		"fox_xform":
			state = form.HUMAN;
			sprite.play("idle");
			get_tree().paused = false;

var girlsteps = [preload("res://audio/Footsteps_Girl1.wav"), preload("res://audio/Footsteps_Girl2.wav"), preload("res://audio/Footsteps_Girl3.wav"), preload("res://audio/Footsteps_Girl4.wav"), preload("res://audio/Footsteps_Girl5.wav"), preload("res://audio/Footsteps_Girl6.wav"), preload("res://audio/Footsteps_Girl7.wav"), ]
var girlstepsdirt = [preload("res://audio/Footsteps_Girl_Dirt1.wav"), preload("res://audio/Footsteps_Girl_Dirt2.wav"), preload("res://audio/Footsteps_Girl_Dirt3.wav"), preload("res://audio/Footsteps_Girl_Dirt4.wav"), preload("res://audio/Footsteps_Girl_Dirt5.wav"), preload("res://audio/Footsteps_Girl_Dirt6.wav"), preload("res://audio/Footsteps_Girl_Dirt7.wav"), ]

var foxsteps = [preload("res://audio/Fox/Footsteps_Fox1.wav"), preload("res://audio/Fox/Footsteps_Fox2.wav"), preload("res://audio/Fox/Footsteps_Fox3.wav"), preload("res://audio/Fox/Footsteps_Fox4.wav"), preload("res://audio/Fox/Footsteps_Fox5.wav"), preload("res://audio/Fox/Footsteps_Fox6.wav"), preload("res://audio/Fox/Footsteps_Fox7.wav"), ]
var foxstepsdirt = [preload("res://audio/Fox/Footsteps_Fox_v2_1 Dirt.wav"), preload("res://audio/Fox/Footsteps_Fox_v2_2 Dirt.wav"), preload("res://audio/Fox/Footsteps_Fox_v2_3 Dirt.wav"), preload("res://audio/Fox/Footsteps_Fox_v2_4 Dirt.wav"), ]

func _on_AnimatedSprite_frame_changed():
	if sprite.animation == "run" and (sprite.frame == 0 or sprite.frame == 4):
		$audio/GirlStep.stream = girlstepsdirt[randi() % len(girlstepsdirt)] if dirty else girlsteps[randi() % len(girlsteps)];
		$audio/GirlStep.play();
	if (sprite.animation == "fox_run_end" and sprite.frame == 1) or sprite.animation == "fox_run" and (sprite.frame == 0 or sprite.frame == 2 or sprite.frame == 3 or sprite.frame == 6):
		$audio/GirlStep.stream = foxstepsdirt[randi() % len(foxstepsdirt)] if dirty else foxsteps[randi() % len(foxsteps)];
		$audio/GirlStep.play();
	if dead and sprite.animation == "death" and sprite.frame == 3:
		$"../..".level_transition(0);


func transform(switch, force):
	if iframes >= 0: return false
	if len($scan.get_overlapping_bodies()) > 1:
		hurt()
		return false
	if (sprite.animation == "idle" or force) and switch:
		sprite.play("xform");
		state = form.XFORM;
		GRAVITY = 800;
		FRICTION = 0.1;
		FRICTION_AIR = 0.02;
		RUN_FORCE = 1300;
		FLY_FORCE = 600;
		JUMP_FORCE = 20000;
		RISE_FORCE = 100;
		$Fox.disabled = false;
		$Human.disabled = true;
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
		$Human.disabled = false;
		$Fox.disabled = true;
		collision_layer = 2;
		collision_mask = 2;
		
		#sprite.offset.x /= -3;
		return true
	return false

func hurt():
	if iframes > 0 or dead: return
	$audio/Hurt.play();
	if not $"../../Health".decrement():
		dead = true;
		stop_music();
	else:
		iframes = 0;
	if state == form.FOX:
		sprite.play("fox_hitflash");
		if dead:
			$"../..".level_transition(0);
	else:
		sprite.play("hitflash");
	

func knock(direction):
	if iframes > 0 or dead: return
	direction.y -= 1.1;
	direction *= 300;
	vel += direction;

func iblink(on):
	if iframes >= 0:
		sprite.material.set_shader_param("enabled", on)

func _ready():
	sprite.material.set_shader_param("enabled", false)


func _on_leaving_body_entered(body, to_right):
	if not body == self: return;
	if not $"../..".level_transition(1 if to_right else -1): return;
	stop_music();

func _on_leaving_body_entered_special(body, to_right):
	if not body == self: return;
	if not $"../..".level_transition(1 if to_right else -1): return;
	$"../..".special_entry = true;
	stop_music();


func stop_music():
	if state == form.FOX:
		$"../Music/tween".play("light_off");
	else:
		$"../Music/tween".play("dark_off");

func collect_book(num):
	$"../..".my_game_data.books[num] = true;
	$"../..".save();

func _on_Dirt_body_entered(body):
	if body == self:
		dirty = true;

func _on_Dirt_body_exited(body):
	if body == self:
		dirty = false;

func _on_Wallslide_finished():
	was_on_wall = -1;

