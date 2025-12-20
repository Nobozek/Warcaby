extends Node

func _ready() -> void:
	%Winner.text = "Winner: " + GameData.winner

func _on_restart_pressed() -> void:
	GameData.turn_of = 1
	GameData.board = [
		[0,2,0,2,0,2,0,2],
		[2,0,2,0,2,0,2,0],
		[0,2,0,2,0,2,0,2],
		[0,0,0,0,0,0,0,0],
		[0,0,0,0,0,0,0,0],
		[1,0,1,0,1,0,1,0],
		[0,1,0,1,0,1,0,1],
		[1,0,1,0,1,0,1,0]
	]
	GameData.possible_moves = []
	GameData.captures = []
	GameData.captureable_pawns = {}
	GameData.capture_possible = false
	GameData.white_pawns = []
	GameData.red_pawns = []
	GameData.winner = ""
	get_tree().change_scene_to_file("res://Elements/Scenes/game_window.tscn")
