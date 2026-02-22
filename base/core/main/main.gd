class_name Main
extends Control

@export var level_container: Node2D
@export var gui: Control

@onready var abilities: AbilityManager = %AbilityManager
@onready var events: EventManager = %EventManager
@onready var enemies: EnemyManager = %EnemyManager
@onready var input: InputManager = %InputManager
@onready var player: Player = %Player
@onready var portal: Portal = %Portal
@onready var stranger: Stranger = %Stranger
@onready var grid: Grid = %Grid
@onready var target_grid: TargetGrid = %TargetGrid
@onready var background: Control = $Background

var current_stage := 0


func _ready():
	GameManager.state_changed.connect(_on_game_state_changed)
	GameManager.init()

	abilities.setup()
	events.setup()
	enemies.setup(grid, player)
	input.setup()
	player.setup(grid)
	portal.setup(grid)
	stranger.setup(grid)
	target_grid.setup(grid)


func _on_game_state_changed(new_state: Global.GameState):
	match new_state:
		Global.GameState.TRANSITION_ANIMATION:
			var tween = get_tree().create_tween()
			tween.tween_property(level_container, "modulate:a", 0.0, 0.2)
			tween.tween_method(_set_star_speed, 0.01, 1.0, 0.2)
			tween.tween_method(_set_star_speed, 1.0, 0.01, 0.2)
			tween.tween_property(level_container, "modulate:a", 1.0, 0.2)
			await tween.finished
			GameManager.set_state(Global.GameState.GENERATE_LEVEL)
			enemies.enemy_count = ceili(current_stage / 5.0)
			abilities.update_slot_count(ceili(current_stage / 4.0) + 3)
			current_stage += 1
			%StageLabel.text = "stage %s" % current_stage

		Global.GameState.GENERATE_LEVEL:
			grid.generate_level(Vector2i(9, 7), 10)
			await grid.level_generated
			GameManager.set_state(Global.GameState.SPAWN_ENTITIES)

		Global.GameState.SPAWN_ENTITIES:
			portal.start_position = grid.get_free_cells().pick_random()
			portal.spawn()
			await portal.spawned
			stranger.start_position = (
				grid
				. get_free_cells()
				. filter(Math.min_distance2.bind(portal.start_position, 3))
				. pick_random()
			)
			stranger.spawn()
			await stranger.spawned
			player.start_position = (
				grid
				. get_free_cells()
				. filter(Math.min_distance3.bind(portal.start_position, stranger.start_position, 2))
				. pick_random()
			)
			player.spawn()
			await player.spawned
			enemies.spawn_enemies()
			await enemies.enemies_spawned
			GameManager.set_state(Global.GameState.WAIT_FOR_COMBAT_INPUT)

		Global.GameState.WAIT_FOR_COMBAT_INPUT:
			var result = await handle_player_combat_input()
			assert(result in [Global.GameState.MOVE_PLAYER, Global.GameState.USE_ABILITY])
			GameManager.set_state(result)

		Global.GameState.MOVE_PLAYER:
			var next_state = Global.GameState.ENEMY_TURN
			var new_player_coords = grid.get_coords(player) + input.direction
			if new_player_coords == grid.get_coords(portal):
				grid.set_cell(grid.get_coords(portal), 0, grid.ground_atlas_coords)
				next_state = Global.GameState.PORTAL_REACHED

			if new_player_coords == grid.get_coords(stranger):
				grid.set_cell(grid.get_coords(stranger), 0, grid.ground_atlas_coords)
				next_state = Global.GameState.PLAY_EVENT

			grid.move(player, input.direction)
			await grid.entity_moved

			GameManager.set_state(next_state)

		Global.GameState.USE_ABILITY:
			await handle_abilities()
			GameManager.set_state(Global.GameState.ENEMY_TURN)

		Global.GameState.PLAY_EVENT:
			events.play_event()
			grid.set_cell(grid.get_coords(stranger), 0, grid.ground_atlas_coords)
			stranger.global_position = Vector2(5000, 5000)
			if events.event_ability == AbilityManager.Ability.EMPTY:
				GameManager.set_state(Global.GameState.ENEMY_TURN)
			else:
				GameManager.set_state(Global.GameState.WAIT_FOR_EVENT_INPUT)

		Global.GameState.WAIT_FOR_EVENT_INPUT:
			while true:
				await input.input_received
				match input.current_mode:
					InputManager.Mode.ACCEPT:
						if not abilities.add_ability(events.event_ability):
							abilities.free_random_slot()
							abilities.add_ability(events.event_ability)
						break

					InputManager.Mode.REJECT:
						Events.ability_lost.emit(events.event_ability)
						break
					_:
						continue

			GameManager.set_state(Global.GameState.ENEMY_TURN)

		Global.GameState.ENEMY_TURN:
			enemies.move_enemies()
			await enemies.enemies_moved
			GameManager.set_state(Global.GameState.HANDLE_DAMAGE)

		Global.GameState.HANDLE_DAMAGE:
			for i in enemies.total_damage:
				if not abilities.free_random_slot():
					Events.level_lose.emit()
					return

			GameManager.set_state(Global.GameState.WAIT_FOR_COMBAT_INPUT)

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
					var new_player_coords = grid.get_coords(player) + input.direction
					if (
						grid.is_ground(grid.get_coords(player) + input.direction)
						or new_player_coords == grid.get_coords(portal)
						or new_player_coords == grid.get_coords(stranger)
					):
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
			print(direction)
			await player.play_laser(direction, ability.range)
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
					await player.play_hook(direction, abs(player_coord.x - cell.x))
					grid.move_to(_get_unit(cell), end_position)
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
				var unit = _get_unit(target_grid.selector_position)
				if is_instance_valid(unit):
					grid.move(unit, direction)
					await grid.entity_moved

			grid.set_cell(target_grid.selector_position, 0, grid.obstical_atlas_coords)


func _set_star_speed(value: float):
	background.material.set_shader_parameter("base_scroll_speed", value)
	background.material.set_shader_parameter("additional_scroll_speed", value)


func _get_unit(coord: Vector2i) -> Node2D:
	if grid.get_coords(stranger) == coord:
		return stranger
	if grid.get_coords(portal) == coord:
		return portal
	return enemies.get_enemy(coord)
