extends State

@export var walk_speed: float = 2.0
@export var jog_speed: float = 3.0

var speed: float = 0.0
var monster: Node3D = null

@onready var mode_switch_timer: Timer = $ModeSwitchTimer

func enter() -> void:
	print("entering lurk")
	
	monster = state_machine.get_parent()
	monster.mode_switch_sound.play()
	mode_switch_timer.start(randf_range(monster.mode_switch_min_time, monster.mode_switch_max_time))
	if monster.intensity > monster.intensity_threshold:
		speed = jog_speed
	else:
		speed = walk_speed


func exit() -> void:
	monster.mode_switch_sound.play()
	mode_switch_timer.stop()
	print("exiting lurk")


func physics_update(_delta: float) -> void:
	if not monster.player:
		return

	monster.velocity = monster.direction * speed
	monster.move_and_slide()
	
	if monster.distance < monster.distance_threshold:
		state_machine.change_state("runstate")
	
	
	## TODO: needs transition into wander state
	


func _on_mode_switch_timer_timeout() -> void:
	if state_machine.previous_state.name.to_lower() == "lurkstate":
		state_machine.change_state("walkstate")
	elif state_machine.previous_state.name.to_lower() == "runstate":
		if monster.intensity > monster.intensity_threshold:
			state_machine.change_state("jogstate")
		else:
			state_machine.change_state("walkstate")
	else:
		state_machine.change_state(state_machine.previous_state.name.to_lower())
