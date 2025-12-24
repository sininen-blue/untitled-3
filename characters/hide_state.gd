extends State

@export var stamina_drain: float = 1.0

var player: CharacterBody3D = null

@onready var hide_regen_timer: Timer = $"../../HideRegenTimer"


func enter() -> void:
	player = state_machine.get_parent()
	player.is_hidden = true
	player.global_position = player.hide_location


func exit() -> void:
	player.is_hidden = false
	player.global_position = player.out_location
	hide_regen_timer.start()


func update(delta: float) -> void:
	player.hide_stamina -= stamina_drain * delta
	
	if player.direction != Vector3.ZERO:
		state_machine.change_state("walkstate")
	if player.hide_stamina <= 0:
		state_machine.change_state("idlestate")


func physics_update(_delta: float) -> void:
	pass


func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed("move_hide"):
		state_machine.change_state("idlestate")
