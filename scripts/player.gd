extends Node2D

@export var ground: TileMapLayer
var cooldown := 0.0
const MOVE_DELAY := 0.12

func get_direction() -> Vector2i:
	var direction = Vector2i.ZERO
	if Input.is_action_pressed("ui_left"):
		direction = Vector2i.LEFT
	elif  Input.is_action_pressed("ui_right"):
		direction = Vector2i.RIGHT
	elif  Input.is_action_pressed("ui_up"):
		direction = Vector2i.UP
	elif Input.is_action_pressed("ui_down"):
		direction = Vector2i.DOWN
	return direction

	

func _ready() -> void:
	position = ground.map_to_local(Vector2i(0, -1))
	
	
func _process(delta: float) -> void:
	cooldown -= delta
	if cooldown > 0:
		return
	var direction = get_direction()
	if direction != Vector2i.ZERO:
		cooldown = MOVE_DELAY
		print(direction)
	
	

	
