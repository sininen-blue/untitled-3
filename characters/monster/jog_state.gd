extends State

@export var speed: float = 1.0

var monster: Node3D = null

@onready var mode_switch_timer: Timer = $ModeSwitchTimer

func enter() -> void:
	print("entering jog")
	
	monster = state_machine.get_parent()
	mode_switch_timer.start(randf_range(monster.mode_switch_min_time, monster.mode_switch_max_time))


func exit() -> void:
	mode_switch_timer.stop()
	print("exiting jog")


func physics_update(_delta: float) -> void:
	if not monster.player:
		return
	
	monster.velocity = monster.direction * speed
	monster.move_and_slide()
	
	if monster.distance < monster.distance_threshold:
		state_machine.change_state("runstate")


func _on_mode_switch_timer_timeout() -> void:
	state_machine.change_state("lurkstate")
