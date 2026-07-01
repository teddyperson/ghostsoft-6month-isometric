extends Enemy3D

func _ready() -> void:
	var sm := AI.StateMachine.new()
	add_child(sm)
	
	var idle := AI.StateIdle.new(self)
	var move_at_player := AI.StateMoveAtPlayer.new(self)
	var wait := AI.StateWait.new(self)
	
	sm.transitions = {
		idle: {
			AI.Event.PLAYER_ENTERED_LINE_OF_SIGHT: move_at_player,
		},
		move_at_player: {
			AI.Event.FINISHED: wait,
			AI.Event.PLAYER_EXITED_LINE_OF_SIGHT: idle,
		},
		wait: {
			AI.Event.FINISHED: idle
		}
	}
	
	sm.activate(idle)
