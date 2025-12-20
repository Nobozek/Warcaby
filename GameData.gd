extends Node

# Colors are marked by id. 1 is for whites, 2 for reds.
var turn_of = 1
var board = [
	[0,2,0,2,0,2,0,2],
	[2,0,2,0,2,0,2,0],
	[0,2,0,2,0,2,0,2],
	[0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0],
	[1,0,1,0,1,0,1,0],
	[0,1,0,1,0,1,0,1],
	[1,0,1,0,1,0,1,0]
]
var possible_moves = []
var captures = []
var captureable_pawns = {}
var capture_possible = false
var selected_pawn: GameFunctions.Pawn
var white_pawns = []
var red_pawns = []
var winner = ""
