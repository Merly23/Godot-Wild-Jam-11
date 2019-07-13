extends TextureRect

export(NodePath) var animator_path
onready var ani = get_node(animator_path)
export(Vector2) var center
export(float) var progress

func _process(delta):
	material.set_shader_param("center", center);
	material.set_shader_param("progress", progress);

func warp(focus):
	var tex = ImageTexture.new();
	var data = get_viewport().get_texture().get_data();
	data.flip_y();
	tex.create_from_image(data);
	texture = tex;
	ani.stop();
	ani.play("default");
	
	center = focus;