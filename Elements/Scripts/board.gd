extends Node2D

@export var white_pawn_scene: PackedScene
@export var red_pawn_scene: PackedScene
@export var possible_move: PackedScene
@export var capture: PackedScene

@onready var pawns_container := $Pawns
@onready var moves_container := $Moves
@onready var captures_container := $Captures

const tile_size = 128
const grid_size = 8

func _ready() -> void:
	spawn_pawns()

func grid_to_world(pos: Vector2i) -> Vector2:
	return Vector2(
		pos.x * tile_size + tile_size / 2,
		pos.y * tile_size + tile_size / 2
	)

func world_to_grid(pos: Vector2) -> Vector2i:
	return Vector2i(
		int(pos.x / tile_size),
		int(pos.y / tile_size)
	)

func spawn_pawn(scene: PackedScene, grid_pos: Vector2i):
	var pawn = scene.instantiate()
	pawns_container.add_child(pawn)
	pawn.set_grid_possition(grid_pos)
	
func spawn_pawns():
	for y in range(grid_size):
		for x in range(grid_size):
			match GameData.board[y][x]:
				1:
					spawn_pawn(white_pawn_scene, Vector2i(x, y))
				2:
					spawn_pawn(red_pawn_scene, Vector2i(x, y))
					
func spawn_possible_move(grid_pos: Vector2i):
	var scene = possible_move
	var pm = scene.instantiate()
	moves_container.add_child(pm)
	pm.set_pos(grid_pos)

func clear_possible_moves():
	for child in moves_container.get_children():
		child.queue_free()

func spawn_possible_moves():
	if !GameData.capture_possible:
		clear_possible_moves()
		clear_captures()
		for pm_pos in GameData.possible_moves:
			spawn_possible_move(Vector2i(pm_pos.x, pm_pos.y))

func move_pawn(pos: Vector2i):
	var pawn = GameData.selected_pawn
	pawn.set_grid_pos(pos)
	var node = pawn.node
	var old_pos = world_to_grid(node.position)
	GameData.board[old_pos.y][old_pos.x] = 0
	node.position = grid_to_world(pos)
	var new_pos = world_to_grid(node.position)
	GameData.board[new_pos.y][new_pos.x] = GameData.turn_of
	clear_possible_moves()
	clear_captures()
	GameData.possible_moves.clear()
	for p in pawns_container.get_children():
		p.hide_highlight()
	next_turn()

func spawn_capture(grid_pos: Vector2i):
	var scene = capture
	var c = scene.instantiate()
	captures_container.add_child(c)
	c.set_pos(grid_pos)

func clear_captures():
	for child in captures_container.get_children():
		child.queue_free()

func spawn_captures():
	clear_captures()
	clear_possible_moves()
	for c_pos in GameData.captures:
		spawn_capture(Vector2i(c_pos.x, c_pos.y))

func capture_func(pos: Vector2i):
	var captured_pawn_pos = Vector2i(GameData.captureable_pawns[Vector2(pos.x,pos.y)])
	match GameData.turn_of:
		1:
			for i in range(GameData.red_pawns.size()):
				if GameData.red_pawns[i].get_grid_pos() == captured_pawn_pos:
					GameData.red_pawns.remove_at(i)
					break
		2:
			for i in range(GameData.white_pawns.size()):
				if GameData.white_pawns[i].get_grid_pos() == captured_pawn_pos:
					GameData.white_pawns.remove_at(i)
					break
	for pawn in pawns_container.get_children():
		if pawn.pawn.get_grid_pos() == captured_pawn_pos:
			GameData.board[captured_pawn_pos.y][captured_pawn_pos.x] = 0
			pawn.queue_free()
	GameData.captureable_pawns.clear()
	GameData.captures.clear()
	GameData.selected_pawn.clear_captures()
	move_pawn(pos)
	GameData.capture_possible = false
	GameData.selected_pawn._show_captures([Vector2(1, 1),Vector2(-1, 1),Vector2(1, -1),Vector2(-1, -1)])
	next_turn()

func next_turn():
	if GameData.red_pawns.size() == 0:
		GameFunctions.end_game("White")
	if GameData.white_pawns.size() == 0:
		GameFunctions.end_game("Red")
	if !GameData.capture_possible:
		if GameData.selected_pawn.get_grid_pos().y == GameData.selected_pawn.y_to_become_queen:
			GameData.selected_pawn.node.become_queen()
		match GameData.turn_of:
			1:
				for p in GameData.white_pawns:
					p.clear_captures()
				GameData.turn_of = 2
			2:
				for p in GameData.red_pawns:
					p.clear_captures()
				GameData.turn_of = 1
		GameData.selected_pawn = null
		GameFunctions.check_captures()


func _on_giveup_pressed() -> void:
	match GameData.turn_of:
		1:
			GameFunctions.end_game("Red")
		2:
			GameFunctions.end_game("White")
