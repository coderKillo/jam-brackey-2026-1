class_name Main
extends Control

@export var level_container: Node2D
@export var gui: Control

@onready var abilities: AbilityManager = %AbilityManager
@onready var events: EventManager = %EventManager
@onready var enemies: EnemyManager = %EnemyManager
@onready var input: InputManager = %InputManager
@onready var player: Player = %Player
@onready var grid: Grid = %Grid
@onready var target_grid: TargetGrid = %TargetGrid
@onready var background: Control = $Background
@onready var level_generator: LevelGenerator = $LevelGenerator

var current_stage := 0


func _ready():
	GameManager.state_changed.connect(_on_game_state_changed)
	GameManager.init()

	abilities.setup()
	events.setup()
	enemies.setup(grid, player)
	input.setup()
	player.setup(grid, target_grid, input)
	target_grid.setup(grid)
	level_generator.setup(background, enemies, grid, level_container)


func _on_game_state_changed(new_state: Global.GameState):
	print(new_state)
	match new_state:
		Global.GameState.GENERATE_LEVEL:
			current_stage += 1
			level_generator.generate_level()
			await level_generator.level_generated
			GameManager.set_state(Global.GameState.ENEMY_DECIDES)

		Global.GameState.ENEMY_DECIDES:
			enemies.enemy_plan()
			await enemies.enemies_plan_finished
			GameManager.set_state(Global.GameState.PLAYER_TURN)

		Global.GameState.PLAYER_TURN:
			player.turn()
			await player.turn_finished

			# TODO: check portal reached or enemies died
			GameManager.set_state(Global.GameState.ENEMY_TURN)

		Global.GameState.ENEMY_TURN:
			enemies.enemy_turn()
			await enemies.enemies_turn_finished
			GameManager.set_state(Global.GameState.ENEMY_DECIDES)

		Global.GameState.ALL_ENEMIES_DIED:
			enemies.clear_enemies()
			player.hide()
			grid.portal.hide()
			GameManager.set_state(Global.GameState.GENERATE_LEVEL)

		Global.GameState.PORTAL_REACHED:
			enemies.clear_enemies()
			player.hide()
			grid.portal.hide()
			GameManager.set_state(Global.GameState.GENERATE_LEVEL)

		Global.GameState.PLAYER_DIED:
			Events.level_lose.emit()
