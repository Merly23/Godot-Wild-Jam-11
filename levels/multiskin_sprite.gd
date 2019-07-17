extends Sprite

export(Texture) var other
var state = false setget enter_state

func enter_state(on):
	if state != on:
		state = on
		
		var temp = texture
		texture = other
		other = temp