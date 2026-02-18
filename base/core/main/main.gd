class_name Main
extends Control

@export var level_container: Node
@export var gui: Control

@onready var abilities: AbilityManager = %AbilityManager
@onready var events: EventManager = %EventManager
@onready var enemies: EnemyManager = %EnemyManager
@onready var input: InputManager = %InputManager
@onready var player: Player = %Player
@onready var portal: Portal = %Portal
@onready var grid: Grid = %Grid


func _ready():
	GameManager.state_changed.connect(_on_game_state_changed)
	GameManager.init()

	abilities.setup()
	events.setup()
	enemies.setup(grid, player)
	input.setup()
	player.setup(grid)
	portal.setup(grid)


func _on_game_state_changed(new_state: Global.GameState):
	match new_state:
		Global.GameState.TRANSITION_ANIMATION:
			GameManager.set_state(Global.GameState.GENERATE_LEVEL)

		Global.GameState.GENERATE_LEVEL:
			grid.generate_level(Vector2i(10, 8))
			await grid.level_generated
			GameManager.set_state(Global.GameState.SPAWN_ENTITIES)

		Global.GameState.SPAWN_ENTITIES:
			player.spawn()
			await player.spawned
			portal.spawn()
			await portal.spawned
			enemies.spawn_enemies()
			await enemies.enemies_spawned
			GameManager.set_state(Global.GameState.WAIT_FOR_COMBAT_INPUT)

		Global.GameState.WAIT_FOR_COMBAT_INPUT:
			await input.input_received
			GameManager.set_state(Global.GameState.MOVE_PLAYER)

		Global.GameState.MOVE_PLAYER:
			grid.move(player, input.direction)
			await grid.entity_moved
			GameManager.set_state(Global.GameState.ENEMY_TURN)

		Global.GameState.USE_ABILITY:
			pass

		Global.GameState.PLAY_EVENT:
			pass

		Global.GameState.WAIT_FOR_EVENT_INPUT:
			pass

		Global.GameState.ENEMY_TURN:
			enemies.move_enemies()
			await enemies.enemies_moved

			if grid.get_coords(player) == grid.get_coords(portal):
				GameManager.set_state(Global.GameState.PORTAL_REACHED)
				return

			GameManager.set_state(Global.GameState.WAIT_FOR_COMBAT_INPUT)

		Global.GameState.HANDLE_DAMAGE:
			pass

		Global.GameState.PORTAL_REACHED:
			enemies.clear_enemies()
			GameManager.set_state(Global.GameState.TRANSITION_ANIMATION)
