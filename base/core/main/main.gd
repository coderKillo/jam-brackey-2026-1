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
@onready var target_grid: TargetGrid = %TargetGrid


func _ready():
	GameManager.state_changed.connect(_on_game_state_changed)
	GameManager.init()

	abilities.setup()
	events.setup()
	enemies.setup(grid, player)
	input.setup()
	player.setup(grid)
	portal.setup(grid)
	target_grid.setup(grid)


func _on_game_state_changed(new_state: Global.GameState):
	match new_state:
		Global.GameState.TRANSITION_ANIMATION:
			GameManager.set_state(Global.GameState.GENERATE_LEVEL)

		Global.GameState.GENERATE_LEVEL:
			grid.generate_level(Vector2i(12, 6), 10)
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
			var result = await handle_player_combat_input()
			assert(result in [Global.GameState.MOVE_PLAYER, Global.GameState.USE_ABILITY])
			GameManager.set_state(result)

		Global.GameState.MOVE_PLAYER:
			grid.move(player, input.direction)
			await grid.entity_moved

			if grid.get_coords(player) == grid.get_coords(portal):
				GameManager.set_state(Global.GameState.PORTAL_REACHED)
				return

			GameManager.set_state(Global.GameState.ENEMY_TURN)

		Global.GameState.USE_ABILITY:
			GameManager.set_state(Global.GameState.ENEMY_TURN)

		Global.GameState.PLAY_EVENT:
			pass

		Global.GameState.WAIT_FOR_EVENT_INPUT:
			pass

		Global.GameState.ENEMY_TURN:
			enemies.move_enemies()
			await enemies.enemies_moved
			GameManager.set_state(Global.GameState.WAIT_FOR_COMBAT_INPUT)

		Global.GameState.HANDLE_DAMAGE:
			pass

		Global.GameState.PORTAL_REACHED:
			enemies.clear_enemies()
			player.hide()
			portal.hide()
			GameManager.set_state(Global.GameState.TRANSITION_ANIMATION)


func handle_player_combat_input() -> Global.GameState:
	var result = Global.GameState.WAIT_FOR_EVENT_INPUT
	while true:
		await input.input_received
		match input.current_mode:
			InputManager.Mode.MOVEMENT:
				target_grid.reset()
				if input.direction != Vector2i.ZERO:
					result = Global.GameState.MOVE_PLAYER
					break

			InputManager.Mode.SELECT_ABILITY:
				abilities.select_slot(input.ability_selected)
				var ability = abilities.get_ability(input.ability_selected)
				target_grid.make_shape(
					ability.shape, grid.local_to_map(player.position), ability.range
				)

			InputManager.Mode.SELECT_CELL:
				target_grid.move_selector(input.direction)

			InputManager.Mode.CAST_ABILITY:
				result = Global.GameState.MOVE_PLAYER
				break
	return result
