extends Node2D

@export var ground: TileMapLayer
var cooldown := 0.0
const MOVE_DELAY := 0.12
var cell: Vector2i 
const TOP_ROW := -1

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
	
func update_position() -> void:
	position = ground.map_to_local(cell)

	

func _ready() -> void:
	cell = Vector2i(0, -1)
	update_position()
	
	
	
func _process(delta: float) -> void:
	cooldown -= delta
	if cooldown > 0:
		return
	var direction = get_direction()
	if direction != Vector2i.ZERO:
		cooldown = MOVE_DELAY
		
		var target = cell + direction
		var world_rect = ground.get_used_rect()
		var right_edge = world_rect.position.x + world_rect.size.x - 1
		var left_edge = world_rect.position.x
		if target.x < left_edge or target.x > right_edge or target.y < TOP_ROW:
			return
			
		if ground.get_cell_source_id(target) != -1:
			ground.erase_cell(target)
			
			
		cell = target
		update_position()
