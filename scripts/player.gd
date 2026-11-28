extends CharacterBody2D

@export var ground: TileMapLayer

const  SPEED := 55.0
const GRAVITY := 420.0
const MAX_FALL := 260.0
const DIG_DELAY := 0.3
const CLIMB_SPEED := 70.0
const FALL_DEATH := 96.0

var stepping := false
var step_dir := 0.0
var climb_target := 0.0
var last_dig := -10.0
var last_dir := Vector2i.ZERO
var falling := false
var fall_start := 0.0
var dead := false
signal gold_changed(total: int)
var gold := 0

func _check_fall() -> void:
	if is_on_floor() or _on_ladder() or stepping:
		if falling and is_on_floor() and global_position.y - fall_start >= FALL_DEATH:
			_die()
		falling = false
	elif not falling:
		falling = true
		fall_start = global_position.y
		
func _die() -> void:
	dead = true
	velocity = Vector2.ZERO
	modulate = Color(1, 0.3, 0.3)
	
func _unhandled_input(event: InputEvent) -> void:
	if dead and event is InputEventKey and event.pressed  and event.keycode == KEY_R:
		get_tree().reload_current_scene()


func _solid(cell: Vector2i) -> bool:
	var id := ground.get_cell_source_id(cell)
	return id == 0 or id == 2 or id == 3
	
func _diggable(cell: Vector2i) -> bool:
	var id := ground.get_cell_source_id(cell)
	return id == 0 or id == 3
	
func _break_cell(cell: Vector2i) -> void:
	if ground.get_cell_source_id(cell) == 3:
		gold += 1
		gold_changed.emit(gold)
	ground.erase_cell(cell)

func _step_up() -> void:
	if not (is_on_floor() or _on_ladder()):
		return
	var cell := ground.local_to_map(ground.to_local(global_position))
	if cell.y < 0:
		return
	var above := cell + Vector2i.UP
	if _solid(above):
		if not _diggable(above):
			return
		_break_cell(above)
	if ground.get_cell_source_id(cell) != 1:
		ground.set_cell(cell, 1, Vector2i(0, 0))
	climb_target = ground.to_global(ground.map_to_local(above)).y
	step_dir = -1.0
	stepping = true

func _step_down() -> void:
	if not _on_ladder():
		return
	var cell := ground.local_to_map(global_position)
	var below := cell + Vector2i.DOWN
	var src_below := ground.get_cell_source_id(below)
	if _solid(below):
		return
	if src_below != 1 and ground.get_cell_source_id(cell) != 1:
		return
	climb_target = ground.to_global(ground.map_to_local(below)).y
	step_dir = 1.0
	stepping = true

func _on_ladder() -> bool:
	var cell := ground.local_to_map(ground.to_local(global_position))
	return ground.get_cell_source_id(cell) == 1 or ground.get_cell_source_id(cell + Vector2i.DOWN) == 1
	
func _climb() -> void:
	velocity.y = 0.0
	if stepping:
		velocity.y = step_dir * CLIMB_SPEED
		if (global_position.y - climb_target) * step_dir >= -1.0:
			global_position.y = climb_target
			stepping = false
			velocity.y = 0.0

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

	if direction == Vector2i.ZERO:
		return
	var cell := ground.local_to_map(ground.to_local(global_position)) + direction
	if not _diggable(cell):
		return
	var now := Time.get_ticks_msec() / 1000.0
	if is_new or now - last_dig >= DIG_DELAY:
		_break_cell(cell)
		last_dig = now
	
func _physics_process(delta: float) -> void:
	if dead:
		return
		
	if not stepping:
		if Input.is_action_pressed("ui_up"):
			_step_up()
		elif Input.is_action_pressed("ui_down"):
			_step_down()
		
	if _on_ladder() or stepping:
		_climb()
	else:
		velocity.y  = min(velocity.y + GRAVITY * delta, MAX_FALL)
		
	if Input.is_action_pressed("ui_down"):
		var col := ground.local_to_map(ground.to_local(global_position)).x
		var center_x := ground.to_global(ground.map_to_local(Vector2i(col, 0))).x
		velocity.x = clampf((center_x - global_position.x) * 12.0, -SPEED, SPEED)
	else:
		velocity.x = Input.get_axis("ui_left", "ui_right") * SPEED
	move_and_slide()
	_check_fall()
	_dig(delta)
