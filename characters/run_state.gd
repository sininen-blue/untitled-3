extends State

@export var speed: float = 10.0
@export var accel: float = 0.2
@export var stamina_drain: float = 1.0

var player: CharacterBody3D = null

@onready var stamina_regen_timer: Timer = $"../../StaminaRegenTimer"


func enter() -> void:
	print("player IN run")
	player = state_machine.get_parent()


func exit() -> void:
	stamina_regen_timer.start()


func update(delta: float) -> void:
	player.stamina -= stamina_drain * delta
	if player.input_dir == Vector2.ZERO:
		state_machine.change_state("idlestate")
	if player.stamina <= 0:
		state_machine.change_state(state_machine.previous_state.name.to_lower())


func physics_update(_delta: float) -> void:
	player.current_speed = move_toward(player.current_speed, speed, accel)
	player.velocity.x = player.direction.x * player.current_speed
	player.velocity.z = player.direction.z * player.current_speed

	player.move_and_slide()


func handle_input(event: InputEvent) -> void:
	if event.is_action_released("move_run"):
		state_machine.change_state("walkstate")
	if event.is_action_pressed("move_jump") and player.stamina > player.jump_threshold:
		state_machine.change_state("jumpstate")
