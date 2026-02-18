extends Node

const INIT_STATE = Global.GameState.TRANSITION_ANIMATION

signal state_changed(new_state: Global.GameState)

var current_state := Global.GameState.INIT
var _next_state := Global.GameState.INIT


func init():
	set_state(INIT_STATE)


func _process(_delta):
	if current_state == _next_state:
		return

	current_state = _next_state
	state_changed.emit(current_state)


func set_state(new_state: Global.GameState):
	# queue state to send signal on next frame
	_next_state = new_state
