extends Node2D
@export var ground: TileMapLayer

const MOVE_DELAY := 0.12
const FALL_DELAY := 0.06
const SAFE_FALL := 3
const TOP_ROW := -1
const DIRT := 0
const LADDER := 1

var cooldown := 0.0
var fall_count := 0
var is_dead := false
var cell: Vector2i

func is_ladder(c: Vector2i) -> bool:
	return ground.get_cell_source_id(c) == LADDER

func die() -> void:
	if is_dead:
		return
	is_dead = true
	$Polygon2D.color = Color.RED
	print("you died, press R") 

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
	
func is_empty(c: Vector2i) -> bool:
	return ground.get_cell_source_id(c) == -1


func _ready() -> void:
	cell = Vector2i(0, -1)
	update_position()


func _process(delta: float) -> void:
	if is_dead:
		if Input.is_action_just_pressed("restart"):
			get_tree().reload_current_scene()
		return
		
	cooldown -= delta
	if cooldown > 0:
		return
		
	# Gravity
	if is_empty(cell + Vector2i.DOWN) and not is_ladder(cell):
		cooldown = FALL_DELAY
		cell += Vector2i.DOWN
		fall_count += 1
		update_position()
		return
		
	# landed: was the fall too long?
	if fall_count > SAFE_FALL:
		die()
		return
	fall_count = 0
	
	# input
	var direction = get_direction()
	if direction != Vector2i.ZERO:
		cooldown = MOVE_DELAY
		
		var target = cell + direction
		var world_rect = ground.get_used_rect()
		var right_edge = world_rect.position.x + world_rect.size.x - 1
		var left_edge = world_rect.position.x
		if target.x < left_edge or target.x > right_edge or target.y < TOP_ROW:
			return
		# going up into empty air: leave a ladder behind in the cell you're leaving
		if direction == Vector2i.UP and is_empty(target) and not is_ladder(cell):
			ground.set_cell(cell, LADDER, Vector2i(0, 0))
			
		# dig dirt, but walk through ladders
		if not is_empty(target) and not is_ladder(target):
			ground.erase_cell(target)
			
		cell = target
		update_position()
