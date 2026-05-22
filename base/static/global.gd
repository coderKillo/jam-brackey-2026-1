class_name Global
extends Node

enum GameState {
	SETUP,
	# start level loop
	GENERATE_LEVEL,
	# start turn loop
	ENEMY_DECIDES,
	PLAYER_TURN,
	ENEMY_TURN,
	# end turn loop
	PORTAL_REACHED,
	ALL_ENEMIES_DIED,
	# end level loop
	PLAYER_DIED,
}

const CELL_SIZE = 32
