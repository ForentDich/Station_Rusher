extends Node

func generate_entrance(index: int):
	return get_child(index).duplicate()

func delete_entrance_in_area(node):
	if(node.get_node("CheckRoomArea2D").get_overlapping_areas().size() == 0):
		node.queue_free()
