extends Node2D
@export var ground: TileMapLayer


func _ready() -> void:
	print("player ready. ground = ", ground)
	position = ground.map_to_local(Vector2i(0, -1))
