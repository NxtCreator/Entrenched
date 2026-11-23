extends Node2D


func _ready() -> void:
	$Ground.set_cell(
		Vector2i(0, 0),
		0,
		Vector2i(0, 0)
	)
