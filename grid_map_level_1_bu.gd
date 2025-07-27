@tool
extends GridMap

@export var remove_tile_92 := false:
	set(value):
		if value:
			clear_tile_index(92)
			remove_tile_92 = false  # Reset the toggle

func clear_tile_index(target_id: int):
	var gridmap := self  # Adjust to the path of your GridMap node
	if not gridmap:
		push_error("GridMap not found.")
		return

	var count := 0
	for cell in gridmap.get_used_cells():
		if gridmap.get_cell_item(cell) == target_id:
			gridmap.set_cell_item(cell, -1)
			count += 1

	print("Cleared", count, "tiles with index", target_id)
