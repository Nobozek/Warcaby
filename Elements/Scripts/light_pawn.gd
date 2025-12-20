extends CharacterBody2D

@onready var board := get_parent().get_parent() as Node2D

var pawn = GameFunctions.Pawn.new(1, [Vector2(1, -1),Vector2(-1, -1)], self, 0)
var queen

func _ready() -> void:
	input_event.connect(pawn._on_input_event)
	GameData.white_pawns.append(pawn)

func set_grid_possition(pos: Vector2i):
	pawn.set_grid_pos(pos)
	position = board.grid_to_world(pos)

func highlight_pawn():
	if pawn._captures != []:
		$Can_Capture.visible = true
		GameData.capture_possible = true

func show_captures():
	board.spawn_captures()

func show_moves():
	board.spawn_possible_moves()

func hide_highlight():
	$Can_Capture.visible = false

func become_queen():
	for i in range(GameData.white_pawns.size()):
		if GameData.white_pawns[i].get_grid_pos() == pawn.get_grid_pos():
			GameData.white_pawns.remove_at(i)
			break
	input_event.disconnect(pawn._on_input_event)
	pawn = null
	pawn = GameFunctions.Queen.new(1, self)
	GameData.white_pawns.append(pawn)
	pawn.set_grid_pos(board.world_to_grid(position))
	$Crown.visible = true
	input_event.connect(pawn._on_input_event)
