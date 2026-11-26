extends Node2D

const WIDTH = 40
const DEPTH = 20

func _ready() -> void:
	for y in range(DEPTH):
		for x in range(WIDTH):
			$Ground.set_cell(
				Vector2i(x, y),
				0,
				Vector2i(0, 0)
			)
	for y in range(-4, 0):
		$Ground.set_cell(Vector2i(20, y), 1, Vector2i(0, 0))
