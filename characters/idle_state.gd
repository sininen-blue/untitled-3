extends State


func enter() -> void:
	print("entering idle")


func exit() -> void:
	print("exiting idle")


func _on_start_timer_timeout() -> void:
	state_machine.change_state("walkstate")
