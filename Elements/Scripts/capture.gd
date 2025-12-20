extends Area2D

@onready var board := get_parent().get_parent() as Node2D

func _ready() -> void:
	input_event.connect(_on_input_event)

func set_pos(pos: Vector2i):
	position = board.grid_to_world(pos)

func _on_input_event(viewport, event: InputEvent, shape_idx):
	if event is InputEventMouseButton and event.is_pressed():
		board.capture_func(board.world_to_grid(position))
