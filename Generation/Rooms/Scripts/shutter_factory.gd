extends Node

func generate_shutter(index: int):
	return get_child(index).duplicate()
