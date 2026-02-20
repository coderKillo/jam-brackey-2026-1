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
			grid.generate_level(Vector2i(10, 7), 10)
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
			await handle_abilities()
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
				abilities.reset()
				if input.direction != Vector2i.ZERO:
					if grid.is_ground(grid.get_coords(player) + input.direction):
						result = Global.GameState.MOVE_PLAYER
						break
					else:
						Events.camera_shake.emit(0.2)

			InputManager.Mode.SELECT_ABILITY:
				abilities.select_slot(input.ability_selected)
				var ability = abilities.get_ability(input.ability_selected)
				target_grid.make_shape(
					ability.shape, grid.local_to_map(player.position), ability.range
				)

			InputManager.Mode.SELECT_CELL:
				if not abilities.is_slot_valid(input.ability_selected):
					Events.camera_shake.emit(0.2)
					input.cancel()
					continue

				if abilities._slots[input.ability_selected].cooldown > 0:
					Events.camera_shake.emit(0.2)
					input.cancel()
					continue

				match abilities.get_ability(input.ability_selected).shape:
					TargetGrid.Shapes.NONE:
						result = Global.GameState.USE_ABILITY
						break
					_:
						target_grid.move_selector(input.direction)

			InputManager.Mode.CAST_ABILITY:
				if abilities.is_slot_valid(input.ability_selected):
					result = Global.GameState.USE_ABILITY
					break
				else:
					Events.camera_shake.emit(0.2)
	return result


func handle_abilities():
	abilities.cast_ability(input.ability_selected)
	var ability = abilities.get_ability(input.ability_selected)
	var player_coord = grid.get_coords(player)
	var direction = Math.vector2i_direction(player_coord, target_grid.selector_position)

	match ability.ability:
		AbilityManager.Ability.SHOOT:
			enemies.take_damage(target_grid.selector_position)
			grid.set_cell(target_grid.selector_position, 0, grid.ground_atlas_coords)

		AbilityManager.Ability.LASER:
			for cell in grid.raycast(player_coord, direction, ability.range):
				enemies.take_damage(cell)

		AbilityManager.Ability.DASH:
			var result = grid.raycast(player_coord, direction, ability.range)
			if not result.is_empty():
				grid.move_to(player, result.back())
				await grid.entity_moved
			for cell in result:
				enemies.take_damage(cell)

		AbilityManager.Ability.HOOK:
			var end_position = player_coord + direction
			for cell in grid.raycast(player_coord, direction, ability.range):
				if grid.is_unit(cell):
					grid.move_to(enemies.get_enemy(cell), end_position)
					await grid.entity_moved
					break

		AbilityManager.Ability.BLINK:
			await VfxManager.spawn_effect(VfxManager.Effect.SPAWN, player.global_position, 3)
			player.hide()
			grid.move_to(player, target_grid.selector_position)
			await grid.entity_moved
			await VfxManager.spawn_effect(VfxManager.Effect.SPAWN, player.global_position, 3)
			player.show()

		AbilityManager.Ability.PUSH:
			for push_direction in TargetGrid.DIRECTIONS:
				var enemy = enemies.get_enemy(player_coord + push_direction)
				if not is_instance_valid(enemy):
					continue
				var result = grid.raycast(player_coord, push_direction, ability.range)
				if result.is_empty():
					continue
				grid.move_to(enemy, result.back())
				await grid.entity_moved

			for push_direction in TargetGrid.DIRECTIONS_DIAGONAL:
				var enemy = enemies.get_enemy(player_coord + push_direction)
				if not is_instance_valid(enemy):
					continue
				var result = grid.raycast(player_coord, push_direction, ability.range - 1)
				if result.is_empty():
					continue
				grid.move_to(enemy, result.back())
				await grid.entity_moved

		AbilityManager.Ability.SHIELD:
			player.shield_value += ability.range

		AbilityManager.Ability.CREATE:
			if grid.is_unit(target_grid.selector_position):
				var enemy = enemies.get_enemy(target_grid.selector_position)
				if is_instance_valid(enemy):
					grid.move(enemy, direction)
					await grid.entity_moved

			grid.set_cell(target_grid.selector_position, 0, grid.obstical_atlas_coords)
