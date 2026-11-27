extends Node2D

const WIDTH = 40
const AHEAD = 30
var generated_to := 1

func _ready() -> void:
	_extend_to(AHEAD)


func _process(delta: float) -> void:
	var py: int = $Ground.local_to_map($Ground.to_local($Player.global_position)).y
	_extend_to(py + AHEAD)

func _extend_to(target_y: int) -> void:
	while generated_to < target_y:
		generated_to += 1
		_generate_row(generated_to)

func _generate_row(y: int) -> void:
	for x in range(WIDTH):
		var source := 0
		if y > 2 and randf() < _stone_chance(y):
			source = 2
		$Ground.set_cell(Vector2i(x, y), source, Vector2i(0, 0))

func _stone_chance(y: int) -> float:
	return clampf(0.10 + y * 0.0008, 0.04, 0.22)
		
