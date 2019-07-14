extends TileMap

export(Texture) var other
var state = false setget enter_state

func enter_state(on):
	if state != on:
		state = on;
		
		
		var temp = tile_set.tile_get_texture(tile_set.get_tiles_ids()[0]);
		for id in tile_set.get_tiles_ids():
			tile_set.tile_set_texture(id, other);
		other = temp;