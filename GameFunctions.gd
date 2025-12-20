extends Node

class Pawn:
	var _color_id
	var _move_dirs
	var _moves = []
	var _captures = []
	var _pawns_to_capture = {}
	var _grid_pos: Vector2i
	var _selected = false
	var _is_queen
	var y_to_become_queen
	var node: Node2D
	
	func _init(color_id, move_dirs, node, y) -> void:
		self._color_id = color_id
		self._move_dirs = move_dirs
		self.node = node
		self.y_to_become_queen = y
		self._is_queen = false
	
	#Getters:
	func get_grid_pos():
		return _grid_pos
	func get_captures():
		return _captures
	func get_move_dirs():
		return _move_dirs
	
	#Setters:
	func set_grid_pos(pos: Vector2i):
		self._grid_pos = pos
	
	func unset():
		self._selected
	
	func _show_possible_moves(pos_x, pos_y):
		self._moves.clear()
		for dir in self._move_dirs:
			var nx = pos_x + dir.x
			var ny = pos_y + dir.y
			if not nx < 0 and nx < 8 and not ny < 0 and ny < 8:
				if GameData.board[ny][nx] == 0:
					_moves.append(Vector2(nx, ny))
		
	func _show_captures(dirs):
		self._captures.clear()
		var pos_x = self._grid_pos.x
		var pos_y = self._grid_pos.y
		var board = GameData.board
		for dir in dirs:
			var mx = pos_x + dir.x
			var my = pos_y + dir.y
			var lx = pos_x + dir.x * 2
			var ly = pos_y + dir.y * 2
			
			#out of board
			if lx < 0 or not lx < 8 or ly < 0 or not ly < 8:
				continue
			
			#is enemy present
			if board[my][mx] != 0 and board[my][mx] != _color_id:
				#is pool behind it free
				if board[ly][lx] == 0:
					self._captures.append(Vector2(lx,ly))
					self._pawns_to_capture[Vector2(lx,ly)] = Vector2(mx,my)
		self.node.highlight_pawn()

	func _is_my_turn():
		if GameData.turn_of == self._color_id: return true
		return false
		
	func _on_input_event(viewport, event: InputEvent, shape_idx):
		if event is InputEventMouseButton and event.is_pressed() && self._is_my_turn():
			if !GameData.capture_possible || self._captures != []:
				GameData.selected_pawn = self
			if self._captures == []:
				self._show_possible_moves(self._grid_pos.x, self._grid_pos.y)
				GameData.possible_moves = self._moves
				self.node.show_moves()
			else:
				GameData.captures = self._captures
				GameData.captureable_pawns = self._pawns_to_capture.duplicate(true)
				self.node.show_captures()

	func clear_captures():
		self._captures = []

class Queen extends Pawn:
	func _init(color_id, node) -> void:
		self._color_id = color_id
		self._grid_pos
		self.node = node
		self._move_dirs = [[Vector2(1,1),Vector2(2,2),Vector2(3,3),Vector2(4,4),Vector2(5,5),Vector2(6,6),Vector2(7,7)],[Vector2(-1,1),Vector2(-2,2),Vector2(-3,3),Vector2(-4,4),Vector2(-5,5),Vector2(-6,6),Vector2(-7,7)],[Vector2(1,-1),Vector2(2,-2),Vector2(3,-3),Vector2(4,-4),Vector2(5,-5),Vector2(6,-6),Vector2(7,-7)],[Vector2(-1,-1),Vector2(-2,-2),Vector2(-3,-3),Vector2(-4,-4),Vector2(-5,-5),Vector2(-6,-6),Vector2(-7,-7)]]
		self._moves = []
		self._captures = []
		self._pawns_to_capture = {}
		self._is_queen = true
	
	func _show_possible_moves(pos_x, pos_y):
		self._moves.clear()
		for i in range(4):
			for j in range(7):
				var nx = pos_x + self._move_dirs[i][j].x
				var ny = pos_y + self._move_dirs[i][j].y
				if not nx < 0 and nx < 8 and not ny < 0 and ny < 8:
					if GameData.board[ny][nx] == 0:
						self._moves.append(Vector2(nx, ny))
					else:
						break
	
	func _show_captures(must_be_useless_value):
		self._captures.clear()
		var pos_x = self._grid_pos.x
		var pos_y = self._grid_pos.y
		var board = GameData.board
		var dir = self._move_dirs
		for i in range(4):
			for j in range(6):
				var mx = pos_x + dir[i][j].x
				var my = pos_y + dir[i][j].y
				var lx = pos_x + dir[i][j+1].x
				var ly = pos_y + dir[i][j+1].y
				#out of board
				if lx < 0 or not lx < 8 or ly < 0 or not ly < 8:
					continue
				
				if board[my][mx] != 0:
					#is enemy present
					if board[my][mx] != _color_id:
						#is pool behind it free
						if board[ly][lx] == 0:
							self._captures.append(Vector2(lx,ly))
							self._pawns_to_capture[Vector2(lx,ly)] = Vector2(mx,my)
					break
		self.node.highlight_pawn()

func check_captures():
	var pawns
	match GameData.turn_of:
		1:
			pawns = GameData.white_pawns
		2:
			pawns = GameData.red_pawns
	for pawn in pawns:
		pawn._show_captures(pawn.get_move_dirs())

func end_game(winner):
	GameData.winner = winner
	get_tree().change_scene_to_file("res://Elements/Scenes/end_game_window.tscn")
