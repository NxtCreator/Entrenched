extends CharacterBody2D

@export var ground: TileMapLayer

const  SPEED := 55.0
const GRAVITY := 420.0
const MAX_FALL := 260.0
const DIG_DELAY := 0.3

var hold_time := 0.0
var last_dir := Vector2i.ZERO

func _dig_dir() -> Vector2i:
	if Input.is_action_pressed("ui_down"): return Vector2i.DOWN
	if Input.is_action_pressed("ui_up"): return Vector2i.UP
	if Input.is_action_pressed("ui_left"): return Vector2i.LEFT
	if Input.is_action_pressed("ui_right"): return Vector2i.RIGHT
	return Vector2i.ZERO
	
func _dig(delta: float) -> void:
	var direction := _dig_dir()
	var is_new := direction != last_dir
	last_dir = direction
	if is_new:
		hold_time = 0.0
	if direction == Vector2i.ZERO:
		return
	var cell := ground.local_to_map(ground.to_local(global_position)) + direction
	if ground.get_cell_source_id(cell) != 0:
		hold_time = 0.0
		return
	hold_time += delta
	if is_new or hold_time >= DIG_DELAY:
		ground.erase_cell(cell)
		hold_time = 0.0
	
func _physics_process(delta: float) -> void:
	var dir := Input.get_axis("ui_left", "ui_right")
	velocity.y  = min(velocity.y + GRAVITY * delta, MAX_FALL)
	if Input.is_action_pressed("ui_down"):
		var col := ground.local_to_map(ground.to_local(global_position)).x
		var center_x := ground.to_global(ground.map_to_local(Vector2i(col, 0))).x
		velocity.x = clampf((center_x - global_position.x) * 12.0, -SPEED, SPEED)
	else:
		velocity.x = Input.get_axis("ui_left", "ui_right") * SPEED
	move_and_slide()
	_dig(delta)
