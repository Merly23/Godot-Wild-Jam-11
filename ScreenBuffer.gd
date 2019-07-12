extends TextureRect

export(Vector2) var center
export(float) var progress

func _process(delta):
	material.set_shader_param("center", center);
	material.set_shader_param("progress", progress);