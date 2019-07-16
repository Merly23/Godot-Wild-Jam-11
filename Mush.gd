extends KinematicBody2D

export var radius = 50;
var home;

func _ready():
	enter_state(false);
	home = position.x;

func enter_state(on):
	#visible = on;
	$Sprite.material.set_shader_param("enabled", not on);
	#$"CollisionShape2D".disabled = true;
	#$"Cap/CollisionShape2D".disabled = true;

func _physics_process(delta):
	var vel = Vector2.ZERO;
	vel.y = 1000 * delta;
	vel.x = 3000 * delta * $Sprite.scale.x;
	
	vel = move_and_slide(vel);
	$Cap.constant_linear_velocity = vel
	
	if position.x > home + radius: $Sprite.scale.x = -1;
	if position.x < home - radius: $Sprite.scale.x = 1;

func _on_Area2D_body_entered(body):
	if body is Player:
		body.hurt();
		body.knock(Vector2.LEFT if position.x > body.position.x else Vector2.RIGHT);