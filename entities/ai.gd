class_name AI extends RefCounted

enum Event {
	NONE,
	FINISHED,
	PLAYER_ENTERED_LINE_OF_SIGHT,
	PLAYER_EXITED_LINE_OF_SIGHT,
	PLAYER_ENTERED_ATTACK_RANGE,
	PLAYER_EXITED_ATTACK_RANGE
}

class Blackboard extends RefCounted:
	static var player_global_position := Vector3.ZERO

class State extends RefCounted:
	
	var name := "State"
	var enemy: Enemy3D = null
	
	signal finished
	
	func _init(init_name: String, init_enemy: Enemy3D) -> void:
		name = init_name
		enemy = init_enemy
	
	func update(_delta: float) -> Event:
		return Event.NONE
	
	func enter() -> void:
		pass
	
	func exit() -> void:
		pass

class StateMachine extends Node:
	
	var transitions := {}: set = set_transitions
	var current_state: State
	
	func set_transitions(new_transitions: Dictionary) -> void:
		transitions = new_transitions
		if OS.is_debug_build():
			for state: State in transitions:
				assert(
					state is State,
					"Invalid state in the transitions dictionary. " +
					"Expected a State object, but got " + str(state)
				)
				for event: Event in transitions[state]:
					assert(
						event is Event,
						"Invalid event in the transitions dictionary. " +
						"Expected an Event object, but got " + str(event)
					)
					assert(
						transitions[state][event] is State,
						"Invalid state in the transitions dictionary. " +
						"Expected a State object, but got " +
						str(transitions[state][event])
					)
	
	func _ready() -> void:
		set_physics_process(false)
	
	func activate(initial_state: State = null) -> void:
		if initial_state != null:
			current_state = initial_state
		assert(
			current_state != null,
			"Activated the state machine but the state variable is null. " +
			"Please assign a starting state to the state machine."
		)
		current_state.finished.connect(_on_state_finished.bind(current_state))
		current_state.enter()
		print("[SM] -- Entered state: %s" % [current_state.name])
		set_physics_process(true)
	
	func _physics_process(delta: float) -> void:
		var event := current_state.update(delta)
		if event == Event.NONE:
			return
		trigger_event(event)
	
	func trigger_event(event: Event) -> void:
		if not current_state in transitions:
			return
		if not transitions[current_state].has(event):
			print_debug(
				"Trying to trigger event " + Event.keys()[event] +
				" from state " + current_state.name +
				" but the transition does not exist."
			)
			return
		var next_state: State = transitions[current_state][event]
		_transition(next_state)
	
	func _transition(new_state: State) -> void:
		current_state.exit()
		print("[SM] -- Exited state [%s] and entering state [%s]" % [current_state.name, new_state.name])
		current_state.finished.disconnect(_on_state_finished)
		current_state = new_state
		current_state.finished.connect(_on_state_finished.bind(current_state))
		current_state.enter()
	
	func _on_state_finished(finished_state: State) -> void:
		assert(
			Event.FINISHED in transitions[finished_state],
			"Received a state that does not have a transition for the FINISHED event, " + current_state.name + ". " +
			"Add a transition for this event in the transitions dictionary."
		)
		_transition(transitions[finished_state][Event.FINISHED])

class StateIdle extends State:
	func _init(init_enemy: Enemy3D) -> void:
		super("Idle", init_enemy)
	
	func update(_delta: float) -> Event:
		var distance := enemy.global_position.distance_to(Blackboard.player_global_position)
		if distance > enemy.vision_range:
			return Event.NONE
		
		return Event.PLAYER_ENTERED_LINE_OF_SIGHT

class StateMoveAtPlayer extends State:
	var duration := 2.0
	var _time := 0.0
	
	func _init(init_enemy: Enemy3D) -> void:
		super("Move at Player", init_enemy)
	
	func enter() -> void:
		_time = 0.0
	
	func update(delta: float) -> Event:
		_time += delta
		if _time >= duration:
			return Event.FINISHED
		var player_distance := enemy.global_position.distance_to(
			Blackboard.player_global_position
		)
		if player_distance > enemy.vision_range:
			return Event.PLAYER_EXITED_LINE_OF_SIGHT
		
		var direction := enemy.global_position.direction_to(Blackboard.player_global_position)
		enemy.velocity = direction * enemy.speed
		enemy.move_and_slide()
		
		return Event.NONE

class StateWait extends State:
	var duration := 2.0
	var _time := 0.0
	
	func _init(init_enemy: Enemy3D) -> void:
		if init_enemy.wait_state_duration:
			duration = init_enemy.wait_state_duration
		super("Wait", init_enemy)
	
	func enter() -> void:
		_time = 0.0
	
	func update(delta: float) -> Event:
		_time += delta
		
		if _time > duration:
			return Event.FINISHED
		
		return Event.NONE
