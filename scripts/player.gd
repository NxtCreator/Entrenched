extends CharacterBody2D

@export var ground: TileMapLayer

const  SPEED := 55.0
const GRAVITY := 420.0
const MAX_FALL := 260.0
const DIG_TIME := 0.3

var dig_time := 0.0
var dig_cell := Vector2i.ZERO

func _dig_dir() -> Vector2i:
	if Input.is_action_pressed("ui_down"): return Vector2i.DOWN
	if Input.is_action_pressed("ui_up"): return Vector2i.UP
	if Input.is_action_pressed("ui_left"): return Vector2i.LEFT
	if Input.is_action_pressed("ui_right"): return Vector2i.RIGHT
	return Vector2i.ZERO
	
func _dig(delta: float) -> void:
	var direction := _dig_dir()
	var cell := ground.local_to_map(ground.to_local(global_position)) + direction
	if direction == Vector2i.ZERO or ground.get_cell_source_id(cell) != 0:
		dig_time = 0.0
		return
	if cell != dig_cell:
		dig_cell = cell
		dig_time = 0.0
	dig_time += delta
	if dig_time >= DIG_TIME:
		ground.erase_cell(cell)
		dig_time = 0.0

func _physics_process(delta: float) -> void:
	var dir := Input.get_axis("ui_left", "ui_right")
	velocity.y  = min(velocity.y + GRAVITY * delta, MAX_FALL)
	velocity.x = dir * SPEED
	move_and_slide()
	_dig(delta)
