extends State

@export var speed: float = 5.0

var monster: Node3D = null


func enter() -> void:
	print("entering run")
	
	monster = state_machine.get_parent()


func exit() -> void:
	print("exiting run")


func physics_update(_delta: float) -> void:
	if not monster.target:
		return
	
	monster.velocity = monster.direction * speed
	monster.move_and_slide()
	
	if monster.distance > monster.distance_threshold:
		state_machine.change_state(state_machine.previous_state.name.to_lower())
