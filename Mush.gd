extends KinematicBody2D

export var radius = 50;
var home;

func _ready():
	enter_state(false);
	home = position.x;

func enter_state(on):
	#visible = on;
	$AnimatedSprite.material.set_shader_param("enabled", not on);
	#$"CollisionShape2D".disabled = true;
	#$"Cap/CollisionShape2D".disabled = true;

func _physics_process(delta):
	var vel = Vector2.ZERO;
	if $AnimatedSprite.animation == "walk":
		vel.y = 1000 * delta;
		vel.x = 3000 * delta * $AnimatedSprite.scale.x;
	
	vel = move_and_slide(vel);
	$Cap.constant_linear_velocity = vel
	
	if (position.x > home + radius and $AnimatedSprite.scale.x == 1) or (position.x < home - radius and $AnimatedSprite.scale.x == -1):
		$AnimatedSprite.play("turn");

func _on_Area2D_body_entered(body):
	if body is Player:
		body.knock(Vector2.LEFT if position.x > body.position.x else Vector2.RIGHT);
		body.hurt();

func _on_AnimatedSprite_animation_finished():
	if $AnimatedSprite.animation == "turn":
		$AnimatedSprite.scale.x *= -1
		$AnimatedSprite.play("turn2");
	elif $AnimatedSprite.animation == "turn2":
		$AnimatedSprite.play("walk");

var steps = [preload("res://audio/MushroomMan/Footsteps_MushroomMan1.wav"), preload("res://audio/MushroomMan/Footsteps_MushroomMan2.wav"), preload("res://audio/MushroomMan/Footsteps_MushroomMan3.wav"), preload("res://audio/MushroomMan/Footsteps_MushroomMan4.wav"), preload("res://audio/MushroomMan/Footsteps_MushroomMan5.wav"), ]

func _on_AnimatedSprite_frame_changed():
	if $AnimatedSprite.animation == "walk" and ($AnimatedSprite.frame == 1 or $AnimatedSprite.frame == 7):
		$step.stream = steps[randi() % len(steps)];
		$step.play();
