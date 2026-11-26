extends CharacterBody2D

@export var ground: TileMapLayer

const  SPEED := 55.0
const GRAVITY := 420.0
const MAX_FALL := 260.0

func _physics_process(delta: float) -> void:
	velocity.y  = min(velocity.y + GRAVITY * delta, MAX_FALL)
	velocity.x = Input.get_axis("ui_left", "ui_right") * SPEED
	move_and_slide()
